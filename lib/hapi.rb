require "rubygems" # TODO remove when gemified
require "rest_client"
require "json"
require "nokogiri"

class Hapi
  VERSION = '0.1.0'

  attr_accessor :host, :resource

  def initialize(host = "http://example.com")
    @host ||= URI.parse( ENV["hapi_host"] || host )
    @resource ||= RestClient::Resource.new @host.to_s
  end

  def host
    @host.to_s
  end

  def jobs
    @jobs ||= initialize_jobs
  end

  ##
  # Reload /api/json
  #
  def update_jobs
    # I might need to reinitiailze
    @jobs = initialize_jobs
  end

  def get path, opts = {}
    # allow symbals
    @resource[path.to_s].get get_default_options.merge( opts )
  end

  def get_parsed *args
    parse_body get(*args)
  end

  def post path, data
    begin
      @resource[path.to_s].post data.to_s, :content_type => 'text/plain'
    rescue RestClient::Exception => e
      raise e
    end
  end

  def post_parsed *args
    # not sure if post returns either of these...
    parse_body post(*args)
  end

  def parse_body body
    begin
      case body
      when /^\s*<\?xml/ then
        Nokogiri::XML body
      when /^\s*\{/ then
        JSON.parse body
      else 
        # TODO fix me.
        raise "unrecognized response."
      end
    rescue => e
      raise "unparsable response. #{e.message}"
    end
  end

  private
    def initialize_jobs
      Hapi::Jobs.new(self)
    end

    def get_default_options
      {:accept => "text/plain"}
    end


end

require "hapi/mixin"
require "hapi/common"
require "hapi/jobs"
require "hapi/job"

##
# @hud = Hapi.new "http://hudson.int.atti.com"
#
# @hud.jobs # => Hapi::Jobs
#
# @hud.jobs.find {|j| j.name =~ "rservices-main"}
# @job = @hud.jobs.find_by_name "rservices-main"
#
# @job.scm_url # => "https://subversion/rservices/branches/1.1"
#
# @job.scm_url = "https://subversion/rservices/branches/1.2"
#
# @job.update_scm! # => 200 ok
