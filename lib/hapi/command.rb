require "hapi"
require "optparse"
require "yaml"

class Hapi::Command < Hapi::Common
  require "hapi/command/exec"
  # all the run_ commands
  extend Hapi::Command::Exec

  class << self
    def run
      parse_options
      send @command
      if @options[:irb]
        run_start_irb
      end
    end

    # commands:
    def hapi
      puts <<-EOS

@hud, and @job (if defined) are available for you.
self is Hapi::Command
prepend `run_' to hapi command to run in console"
set_job "job name" sets @job

      EOS
    end

    def run_start_irb
      puts <<-EOS
Welcome to hapi irb console.
type hapi for help.
      EOS
      require "hapi/command/irb_start"
      # turn job names into methods
      extend Hapi::Command::Irb
      IRB.start_session(binding)
    end

    # common commands
    def hud_host
      ENV["hapi_host"] || config[:hapi][:host] || raise_usage( "no hapi_host defined." )
    end

    def config
      @config = {}
      begin
        @config.merge! YAML.load_file( hapi_rc )
      rescue Errno::ENOENT
        # rescue unparsable YAML
      end
      @config
    end

    def hapi_rc
      # we should actually load all of them.
      # this is my least favoriate method :/
      homerc = File.expand_path("~/.hapirc")
      pwdrc  = File.join(Dir.pwd, "hapirc")
      librc  = File.join(File.dirname(__FILE__), "..", "assets", "hapirc")
      case
      when File.file?( pwdrc )
        pwdrc
      when File.file?( homerc )
        homerc
      when File.file?( librc )
        librc
      end
    end

    # helpers:
    def usage_msg
      usage = <<-EOB

Usage: hapi [opts] commands [job_name]

  Commands:   unambiguous
  +build+::   start a job building.
  +list+::    list jobs. [job_name used as filter].
  +config+::  pretty print job config. job_name

        EOB
    end

    def raise_usage msg = nil
      warn msg if msg
      puts usage_msg
      exit 1
    end

    def parse_options
      # initialize cmd_list. This seems hacky, but I like having the cmd_list
      # near the usage statement.
      usage_msg
      config
      @options = {}

      OptionParser.new do |opts|
        opts.banner = usage_msg

        opts.on("--hud-host HOST", "Hudson host to connect to") do |h|
          @options[:hapi_host] = h
          @config[:hapi][:host] = h
        end

        opts.on("-i", "Drop into irb.
                      @hud is defined as Hapi.new
                      @job is defined if job_name is specified") do |i|
          @options[:irb] = i
        end
        opts.on("-v", "--[no]-verbose", "Turn on verbose messages.") do |v|
          $VERBOSE = @options[:verbose] = v
        end

        opts.on_tail("--version", "Show version") do
          puts "Hapi (#{Hapi::VERSION}) (c) 2010"
          exit
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end.parse!


      @command, @job_name = ARGV.shift(2)
      @command ||= "default"

      @hud = Hapi.new hud_host
      set_job

      parse_command
    end

    def parse_command
      # select unambiguous command to run.
      cmds = cmd_list.select {|c| Regexp.new(@command.to_s, Regexp::IGNORECASE) === c}
      case cmds.size
      when 0 then
        raise_usage "#{@command} is not recognized as a valid command."
      when 1 then
        @command = "run_" << cmds.first
      else
        puts usage_msg
        abort "Ambiguous command. Please specify:\n  #{cmds.join("\n  ")}\n\n"
      end
    end

    def set_job job_name = @job_name
      @job = @hud.jobs.find_by_name job_name if job_name
    end
  end
end
