class Hudkins
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
  Welcome to hudkins irb console.
  type hudkins for help.

      EOS
      require "hudkins/command/irb_start"
      # turn job names into methods
      extend Hudkins::Command::Irb
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

    # could probably be cleaned up
    def required_params values
      e = Hudkins::ArgumentError.new ""
      raize = false
      values.each do |k,msg|
        e << msg unless k
        raize = true unless k
      end
      raise e if raize
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
      ENV["hudkins_host"] || config[:host] || raise_usage( "no hudkins_host defined." )
    end

    def config
      @config ||= load_rc
    end

    def load_rc
      hudkins_rc.inject({}) do |ret, rc|
        h = YAML.load_file( rc )
        ret.merge! h if h
        ret
      end
    end

    def hudkins_rc
      [
        File.expand_path("~/.hudkinsrc"),
        File.join(Dir.pwd, ".hudkinsrc")
      ].select {|f| File.size? f} # exists and is non 0
    end

  end
end
