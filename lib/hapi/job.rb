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

  def scm_url
    scm_el.content
  end

  def scm_url= url
    scm_el.content = url
  end

  def update_scm! url = nil
    scm_url = url if url
    post_config
    # not sure why I have to do this..
    self.scm_url
  end

  def build!
    @hapi.get path + "/build"
  end

  def disabled?
    disable_el.context =~ /true/
  end

  def disable
    disable_el.content = true
  end

  def disable!
    disable
    post_config
    disabled?
  end

  def enable
    disable_el.content = false
  end

  def enable!
    enable
    post_config
    disabled?
  end

  def can_roam?
    roam_el.content =~ /true/
  end

  private

    def scm_el
      config.at("//scm//remote")
    end

    def disable_el
      config.at("//properties//disabled")
    end

    def roam_el
      config.at("//properties//canRoam")
    end


end
