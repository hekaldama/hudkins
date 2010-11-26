require "hapi"
require "optparse"
require "yaml"

##
# === Description
# Main class for the included bin to interact with Hudson at the command line.
#
# The Commands are setup in Hapi::Command::Exec
#
# === Usage
# see `hapi -h'
class Hapi::Command
  include Hapi::Common

  require "hapi/command/exec"
  # all the run_ commands
  extend Hapi::Command::Exec

  class << self
    def run
      parse_options
      begin
        return_string = send( @command )
        puts return_string if return_string
      rescue => e
        raise_usage e.message
      end
      if @options[:irb]
        run_start_irb
      end
    end

    # commands:
    # helpers:
    def usage_msg
      usage = <<-EOB

Usage: hapi [opts] commands [job_name]

  Commands:   unambiguous_partial_command
  build:    start a job building.
  config:   pretty print job config. job_name
  create:   create new hudson job.
  host:     print hudson host url
  list:     list jobs. [job_name used as filter].


  Optional:   job_name (depends on command)
    may also be partial (picks first that matches)

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
      @options = {}

      OptionParser.new do |opts|
        opts.banner = usage_msg

        opts.separator ""
        opts.separator "Specific options:"

        opts.on("--hud-host HOST", "Hudson host to connect to. Overrides rc file") do |h|
          @options[:host] = h
        end

        opts.on("-i", "--irb", "Drop into irb.") do |i|
          @options[:irb] = i
        end
        opts.on("-v", "--[no-]verbose", "Turn on verbose messages.") do |v|
          $VERBOSE = @options[:verbose] = v
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("--version", "Show version") do
          puts "Hapi (#{Hapi::VERSION}) (c) 2010"
          exit
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

      end.parse!

      config.merge! @options

      @command, @job_name = ARGV.shift(2)
      @command ||= "default"

      @hud = Hapi.new hud_host
      job @job_name

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
        raise_usage "Ambiguous command. Please specify:\n  #{cmds.join("\n  ")}\n\n"
      end
    end

  end
end
