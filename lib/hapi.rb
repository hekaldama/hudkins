class Hapi
  VERSION = '1.0.0'

  attr_accessor :host, :url, :version

  class << self #class methods
    def setup &block
      const_set("SETUP", block)
    end
  end

  def initialize 
    SETUP.call(self)
    @host = ENV["host"] if ENV["host"]
    @url ||= ENV["url"]
    @version ||= ENV["version"]
  end
end
