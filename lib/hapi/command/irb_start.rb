require "irb"

# thank you!
# http://jameskilton.com/2009/04/02/embedding-irb-into-your-ruby-application/

module IRB # :nodoc:
  def self.start_session(binding)
    unless @__initialized
      args = ARGV
      ARGV.replace(ARGV.dup)
      IRB.setup(nil)
      ARGV.replace(args)
      @__initialized = true
    end
 
    workspace = WorkSpace.new(binding)
 
    irb = Irb.new(workspace)
 
    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context
 
    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end

module Hapi::Command::Irb
  def method_missing sym, *args, &block
    names = @hud.jobs.names
    if job = names.find {|name| name.gsub(/-/, "_") =~ Regexp.new(sym.to_s, Regexp::IGNORECASE)}
      # any job name (with "-" turned into "_") is a method name in irb
      @hud.jobs.find_by_name job
    else
      super sym, *args, &block
    end
  end

  #def respond_to? sym
    #names = @hud.jobs.names
    #names.include? sym or super sym
  #end
end
