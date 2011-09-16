require "rest_client"
require "json"
require "nokogiri"

require "hudkins/restclient"
require "hudkins/mixin"
require "hudkins/common"

##
# === Description
# Primary class used to interact with your Hudson server
#
# === Examples
#   hud = Hudkins.new "http://my-hudson.localdomain.com:8080"
#   hud.jobs # => Hudkins::Jobs
#   job = hud.jobs.find_by_name :job_name
#
# == Command Line
#   There is an included binary for doing simple commands.
#   See Hudkins::Command#run_start_irb for a powerful way to interact with your
#   hudson server at an irb cmd prompt.
#
class Hudkins
  include Hudkins::Common
  VERSION = '0.1.0'

  attr_reader :host, :resource

  ##
  # === Examples
  #   Hudkins.new <host_name> [opts]
  #
  #   <host_name> will be URI parsed
  #
  # === Options
  # +host_timeout+::  number of seconds to timeout trying to connect to the server. see Hudkins#host_available?
  #
  def initialize(host = "http://example.com", opts = {})
    @host = URI.parse( ENV["hudkins_host"] || host )
    @options = opts
    @resource = RestClient::Resource.new @host.to_s
  end

  ##
  # === Description
  # Reset what Hudkins#host is after initialization. Also updates Hudkins#reset_resource.
  def host= host_name
    @host = URI.parse host_name
    # reinitialize @resource
    resource = @host
  end

  ##
  # === Description
  # Update Hudkins#resource with new host name.
  def reset_resource= uri = host, opts = {}
    @resource = RestClient::Resource.new( uri.to_s, opts)
  end

  ##
  # === Description
  # Access to internal list of jobs. see Hudkins::Jobs
  #
  # One inital api call is made and then cached. See Hudkins#initialize_jobs
  def jobs
    @jobs ||= initialize_jobs
  end

  ##
  # === Description
  # Reload jobs from the server
  def update_jobs
    # I might need to reinitiailze
    @jobs = initialize_jobs
  end

  ##
  # === Description
  # Available to make arbitrary HTTP/get calls to the server.
  # Returns an Hudkins::Response object. (see that class for reasoning.)
  #
  # === Parameters
  # +path+::  "/path/to/resource"
  # +opts+::  {:accept => "text/plain"} (default)
  # +block+:: { optional return block for RestClient#get }
  def get path = nil, opts = {}, &block
    use_resource :get, path, nil, opts, &block
  end

  ##
  # === Description
  # Available to make arbitrary HTTP/post calls to the server.
  #
  # === Parameters
  # +path+::  "/path/to/resource"
  # +data+::  "<?xml...>" (any object that responds to to_s).
  # +opts+::  {:content => "text/plain"} (default)
  # +block+:: { optional return block for RestClient#get }
  def post path = nil, data = "", opts = {}, &block
    use_resource :post, path, data, opts, &block
  end

  ##
  # === Description
  # Same as #get but attempt to parse the response body.
  # Raise unless Response#success?
  def get_parsed *args
    parse_response get(*args)
  end

  ##
  # === Description
  # Same as #post but attempt to parse the response body.
  # Raise unless Response#success?
  def post_parsed *args
    parse_response post(*args)
  end

  # Action methods

  ##
  # === Description
  # TODO this needs cleaned up to be more like copy_job
  # Use remote api to create a new job.
  # Updates internal job list (Hudkins#jobs) afterwards
  #
  # === Example
  #   hud.add_job :job_name, "<?xml..>"
  #
  # === Options
  # +job_name+::    String or Symbol used as the name of the new job.
  # +config_data+:: Uses provided template for bare-bones config, but
  #                 optionally takes a string parameter (such as xml from
  #                 another job's config)
  #
  # === Notes
  # The remote api here is not fun. It uses HTTP#post instead of HTTP#create
  # (which is normal) but the error messages are not very useful.
  def add_job job_name, config_data = new_config
    # yuck..
    job = update_jobs.find_by_name( job_name )
    unless job
      response = post "/createItem?" + url_escape(:name => job_name), config_data, :content_type => "text/xml"
      if response.success?
        update_jobs.find_by_name job_name
      else
        case response.code
        when 400
          warn "the server returned an error. most likely the job name already exists."
          jobs.find_by_name( job_name ) || ( raise response.errors )
        else
          warn "there was a problem."
          raise response.errors
        end
      end
    else
      job
    end
  end

  ##
  # === Description
  # Copy a job
  #
  # === Examples
  #   new_job = hud.copy_job "job-name", "new-job-name"
  #
  #   job = hud.find_by_name "job-name"
  #   new_job = hud.copy_job job, "new-job-name"
  def copy_job job, new_job
    job = Hudkins::Job === job ? job : jobs.find_by_name( job )
    job.copy( new_job ) if job # find_by_name didn't return nil
  end

  ##
  # === Description
  # Gets the hudson version the server is running
  #
  # === Examples
  #   hud.server_version # => "1.37.0"
  def server_version
    get.response.headers[:x_hudson]
  end

  def parse_string string, format
    case format
    when :xml then
      Nokogiri::XML string
    when :json then
      JSON.parse string
    else
      raise "unsupported type #{format.inspect}"
    end
  end

  private
    def initialize_jobs
      Hudkins::Jobs.new(self)
    end

    def get_default_options
      {:accept => "text/plain"}
    end

    def post_default_options
      {:content_type => "text/plain"}
    end

    def new_config
      File.read( File.join( File.dirname(__FILE__), "assets", "free_style_project.xml.erb"  ) )
    end

    def use_resource verb, path, data = nil, opts = {}, &block
      check_host_availability
      # allow symbals
      new_resource = path.nil? ? @resource : @resource[path.to_s]
      args = [ send("#{verb}_default_options").merge( opts ) ]
      # not sure how else to make this generic for both get and post
      # maybe something like opts.delete :data
      args.unshift data.to_s if data
      new_resource.send(verb, *args, &(block || resource_block))
    end

    def resource_block
      # restclient
      # |response, request, result|
      Proc.new {|*args| Response.new *args}
    end

    # body = @response.body, format = @response.format
    def parse_response response
      # I debated on wether or not to push up the raise statement. But it seems like I might want to do a "get" even if it doesn't return a valid response whereas why would I want to parse an invalid response?
      raise response.result unless response.success?
      body, format = response.body, response.type
      begin
        parse_string body, format
      rescue => e
        raise "unparsable response for #{response.request.url}.\n#{e.message}"
      end
    end

    #def parse_response response
      #raise response.result unless response.success?
      #body = response.body
      #begin
        #case body
        #when /^\s*<\?xml/ then
          #Nokogiri::XML body
        #when /^\s*\{/ then
          #JSON.parse body
        #else
          #body
        #end
      #rescue => e
        #raise "unparsable response. #{e.message}"
      #end
    #end
  # private
end # Hudkins

require "hudkins/jobs"
require "hudkins/job"
require "hudkins/errors"
