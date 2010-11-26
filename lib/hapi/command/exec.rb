class Hapi
  ##
  # === Description
  # mixin for interacting with the lib
  #
  # the bin is setup to run any command prefaced with `run_'
  # each command should return something to be puts or nil
  module Command::Exec
    ##
    # default command. here as a place holder
    def run_default
    end

    def run_build
      "building!!!"
    end

    def run_config job_name = @job_name
      required_params job_name => "job_name is required for this command."
      [
        job( job_name ).name,
        job( job_name ).config
      ]
    end

    def run_create job_name = @job_name
      required_params job_name => "job_name is required for this command."
      "creating!!!"
    end

    def run_host
      hud_host
    end

    def run_list job_name = @job_name
      names( job_name || "" )
    end

    def run_start_irb
      puts <<-EOS

  ---
  Welcome to hapi irb console.
  type hapi for help.

      EOS
      require "hapi/command/irb_start"
      # turn job names into methods
      extend Hapi::Command::Irb
      IRB.start_session(nil, binding)
    end

    # helper commands

    def hud
      @hud
    end

    def job job_name = nil
      if job_name
        @job = hud.jobs.find_by_name job_name
      end
      @job
    end

    def required_params values
      values.each do |k,msg|
        raise ArgumentError, msg unless k
      end
    end

    def cmd_list
      command_list.map {|m| m.gsub(/^run_/, '')}
    end

    def command_list
      self.methods.select {|m| m =~ /^run_/}
    end

    def names name = ""
      hud.jobs.names name
    end

    def hud_host
      ENV["hapi_host"] || config[:host] || raise_usage( "no hapi_host defined." )
    end

    def config
      @config ||= load_rc
    end

    def load_rc
      ret = {}
      hapi_rc.each do |rc|
        h = YAML.load_file( rc )
        case h
        when Hash then
          ret.merge! YAML.load_file( rc )
        end
      end
      ret
    end

    def hapi_rc
      [
        File.expand_path("~/.hapirc"),
        File.join(Dir.pwd, "hapirc")
      ].select {|f| File.exists? f}
    end

  end
end
