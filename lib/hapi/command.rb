require "hapi"
require "optparse"

class Hapi::Command < Hapi::Common
  class << self
    def run
      parse_options
      send @command
    end

    def build
      puts "building!!!"
    end

    def list
      puts "listing!!!"
    end

    def config
      puts "configing!!!"
    end

    def usage_msg
      <<-EOB

Usage: hapi [opts] commands [job_name]

  Commands:   unambiguous
  +build+::   start a job building.
  +list+::    list jobs. [job_name used as filter].
  +config+::  pretty print job config. job_name

        EOB
    end

    def parse_options
      @options = {}

      OptionParser.new do |opts|
        opts.banner = usage_msg

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

      @cmd_list = %w(build list config)

      @command, @job_name = ARGV

      parse_command
    end

    def parse_command
      cmd = @cmd_list.select {|c| Regexp.new(@command, Regexp::IGNORECASE) === c}
      case cmd.size
      when 0 then
        puts usage_msg
        exit 1
      when 1 then
        @command = cmd.first
      else
        puts usage_msg
        abort "Ambiguous command. Please specify:\n  #{cmd.join("\n  ")}\n\n"
      end
    end
  end
end