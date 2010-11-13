class Hapi::Job

  include Comparable

  attr_reader :name, :url, :color, :path, :config
  def initialize hapi, data
    @hapi = hapi
    @name = data["name"]
    @url = URI.parse data["url"]
    @color = data["color"]
    @path = @url.path
  end

  def inspect
    # hide instance variables
    @hapi.class.object_inspect self, "@name=`#{name}', ..."
  end

  def url
    @url.to_s
  end

  # Enumerables...
  def <=> other
    # TODO how do I implement jobs.sort(&:path) ?
    self.name <=> other.name
  end

  def config
    @config ||= update_config
  end

  def update_config
    @config = @hapi.get_parsed( path + "/config.xml" )
  end

  def scm_url
    config.at("//scm//remote").content
  end

  def scm_url= url
    config.at("//scm//remote").content = url
  end

  def update_scm! url = nil
    scm_url = url if url
    @hapi.post path + "/config.xml", @config
    update_config
    # not sure why I have to do this..
    self.scm_url
  end

  def build!
    @hapi.get path + "/build"
  end
end
