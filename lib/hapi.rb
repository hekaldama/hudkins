require "rubygems" # TODO remove when gemified
require "rest_client"
require "json"
require "nokogiri"

class Hapi
  VERSION = '0.1.0'

  attr_accessor :host, :url, :version, :resource

  class << self #class methods
    def setup &block
      const_set("SETUP_PROC", block)
    end

    def object_inspect obj, string
      "#{obj.to_s[0..-2]} #{string}>"
      #"#<#{self.class}:0x#{"%x" % (self.object_id << 1)} #{string}>"
    end
  end

  def initialize(host = "http://example.com")
    @host = URI.parse( ENV["hapi_host"] || host )
    @resource ||= RestClient::Resource.new @host.to_s
    #@url ||= ENV["url"]
    #@version ||= ENV["version"]
    #SETUP_PROC.call(self) if Module.const_defined? "SETUP_PROC"
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

  def get path
    # allow symbals
    @resource[path.to_s].get
  end

  def get_parsed path
    parse_body get(path)
  end

  def post path, data
    begin
      @resource[path.to_s].post data.to_s, :content_type => 'text/plain'
    rescue RestClient::Exception => e
      raise e
    end
  end

  def post_hash *args
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
      raise "unparsable response."
    end
  end

  private
    def initialize_jobs
      Hapi::Jobs.new(self)
    end

end

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
