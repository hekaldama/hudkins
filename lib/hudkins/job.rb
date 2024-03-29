# === Description
# Primary class for interacting with a Hudson job
#
# === Examples
#   hud = Hudkins.new "http://hudson.com"
#   job = hud.jobs.find_by_name :job_name
#
#   job.disabled? # => true
#   job.disabled = false
#   job.post_config!
#
# === attr_accessor_from_config methods
#
# I created custom attr_accessor like DSL methods that create accessor like
# methods for the Hudkins::Job object to easily interact with the xml config.
# Paradigm is to use method_name? for boolean values and method_name! for any
# methods that post updates to the server.
#
class Hudkins::Job
  include Hudkins::Common
  extend Hudkins::Mixin

  include Comparable

  attr_reader :name, :url, :color, :path, :config

  #TODO figure out how to define a custom rdoc method to correctly document these

  ##
  # :attr_accessor: scm_url
  attr_accessor_from_config :scm_url,             "//scm//remote"
  ##
  # :attr_accessor: description
  attr_accessor_from_config :description,         "//project//descriptoin"
  ##
  # :attr_accessor: can_roam
  attr_accessor_from_config :can_roam,            "//project//canRoam",                         :bool
  ##
  # :attr_accessor: disabled
  attr_accessor_from_config :disabled,            "//project//disabled",                        :bool
  ##
  # :attr_accessor: blocked_by_upstream
  attr_accessor_from_config :blocked_by_upstream, "//project//blockBuildWhenUpstreamBuilding",  :bool
  ##
  # :attr_accessor: concurrent_builds
  attr_accessor_from_config :concurrent_builds,   "//project//concurrentBuild",                 :bool
  attr_accessor_from_config :mail_recipients,     "//publishers//recipients"
  # this is really an array. I haven't added functionality for that yet
  attr_accessor_from_config :shell_builders,     "//builders/hudson.tasks.Shell",               :array
  ##
  # :attr_accessor: :rotate_logs_num
  # Number of builds to keep
  # -1 == infinite
  attr_accessor_from_config :rotate_logs_num,     "//logRotator/numToKeep",                     :int
  ##
  # :attr_accessor: :rotate_logs_days
  # Number of days to keep builds
  # -1 == infinite
  attr_accessor_from_config :rotate_logs_days,    "//logRotator/daysToKeep",                    Integer

  def initialize hudkins, data
    @hudkins = hudkins
    @name = data["name"]
    @url = URI.parse data["url"]
    @color = data["color"]
    @path = @url.path
  end

  def inspect
    super "@name=#{@name}"
  end

  def url
    @url.to_s
  end

  # Enumerables/Comparables...
  def <=> other
    # TODO how do I implement jobs.sort(&:path) ?
    self.name <=> other.name
  end

  ##
  # === Description
  # get the job's config
  # takes string (xml) or other's config
  def update_config config = nil
    config = case config
    when String then
      hudkins.parse_string( config, :xml )
    when Nokogiri::XML::Document, NilClass then
      config
    else
      raise "unknown config type #{config.class}"
    end
    @config = config || hudkins.get_parsed( path + "/config.xml", :accept => "application/xml" )
  end

  ##
  # === Description
  # accessor for job's config. Initializes then caches. Use update_config if out of date.
  def config
    @config ||= update_config
  end

  ##
  # === Description
  # Post the job's config back to the server to update it.
  def post_config!
    post path + "/config.xml", @config
  end

  def build!
    get path + "/build"
  end

  def delete!
    post path + "/doDelete"
  end

  def recreate!
    hudkins.add_job name, config
  end

  def disable!
    post path + "/disable"
  end

  def enable!
    post path + "/enable"
  end

  ##
  # === Description
  # The remote api allows for updating just the description. I had to tweak the
  # name because I still wanted description to be an attr_accessor_from_config
  #
  # === Example
  #   job.quick_description! # => "this is the description for job"
  #   job.quick_description! = "this is the new desc." # => Response obj
  def quick_description! msg = nil
    # another yuck!
    if msg
      post path + "/description?" + url_escape(:description => msg)
    else
      get( path + "/description" ).body
    end
  end

  ##
  # === Description
  # Copy job to new_job_name
  #
  # === Example
  #   new_job = job.copy "new-job-name"
  #   new_job.scm_url = "http://svn/new/job/path"
  #   new_job.post_config!
  def copy new_job_name
    # post /createItem?name=NEWJOBNAME&mode=copy&from=FROMJOBNAME
    response = post "/createItem?" +
      url_escape(:name => new_job_name, :mode => "copy", :from => name)
    # return new job object
    hudkins.update_jobs.find_by_name new_job_name if response.success?
  end

  # not sure if we want this.
  # alias_method :dup, :copy
end
