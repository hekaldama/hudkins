require "irb"

# thank you!
# http://jameskilton.com/2009/04/02/embedding-irb-into-your-ruby-application/

module IRB # :nodoc:
  # originally used the code snippet from the above link, which turned out to
  # be a snippet from `ruby-debug'. However, I was having problems with CNTR-C
  # and I realized I wanted to mimic irb, just be able to actually pass Irb.new
  # a workspace param which it expected.
  def self.start_session(ap_path = nil, binding = nil)
    @@hack_binding = binding
    IRB.start ap_path
  end

  def self.get_binding
    @@hack_binding
  end

  class Irb
    alias_method :org_initialize, :initialize
    def initialize *args
      workspace = args.shift
      workspace ||= WorkSpace.new(IRB.get_binding)
      args.unshift workspace
      org_initialize *args
    end
  end
end

class Hudkins
  module Command::Irb

    ##
    # In the irb console I want to access the same commands as
    # Hudkins::Command::Exec but without the `run_' part.
    def self.extend_object obj # :doc:
      # in IRB allow run_* commands to be exec without `run_'
      obj.command_list.each do |cmd|
        s = <<-EOE
          def self.#{cmd.gsub(/^run_/, '')} *args; #{cmd} *args; end
        EOE
        obj.module_eval s
      end
      super
    end

    ##
    # This is cool. Override default method to add convenience methods for each
    # job_name in #jobs. This allows `job_name' to be used as a method to
    # access that particular job.
    def method_missing sym, *args, &block
      if job = @hud.jobs.find_by_name( sym )
        job
      else
        super sym, *args, &block
      end
    end

    ##
    # help method in irb console
    def hudkins
      puts <<-EOS

  self is Hudkins::Command
  hudkins            => This help message
  reload!         => reload lib
  hud             => Hudkins.new <hud_host>
  job [job_name]  => Hudkins::Job
  job_name        => Hudkins::Job
  commands:
    #{cmd_list.join("\n    ")}

      EOS
    end

    ##
    # helper method in irb console to reload all the lib files.
    def reload!
      $".grep( /hudkins/ ).each do |f|
        load f
      end
      nil
    end
  end # Command::Irb
end # Hudkins
