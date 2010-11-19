class Hapi::Job < Hapi::Common

  include Comparable

  attr_reader :name, :url, :color, :path, :config
  def initialize hapi, data
    @hapi = hapi
    @name = data["name"]
    @url = URI.parse data["url"]
    @color = data["color"]
    @path = @url.path
  end

  def url
    @url.to_s
  end

  # Enumerables/Comparables...
  def <=> other
    # TODO how do I implement jobs.sort(&:path) ?
    self.name <=> other.name
  end

  def update_config
    @config = @hapi.get_parsed( path + "/config.xml" )
  end

  def config
    @config ||= update_config
  end

  def post_config!
    @hapi.post path + "/config.xml", @config
    update_config
  end

  attr_accessor_from_config :scm_url,             "//scm//remote"
  attr_accessor_from_config :can_roam,            "//project//canRoam",                         :bool
  attr_accessor_from_config :disabled,            "//project//disabled",                        :bool
  attr_accessor_from_config :blocked_by_upstream, "//project//blockBuildWhenUpstreamBuilding",  :bool
  attr_accessor_from_config :concurrent_builds,   "//project//concurrentBuild",                 :bool

  def build!
    @hapi.get path + "/build"
  end
end
