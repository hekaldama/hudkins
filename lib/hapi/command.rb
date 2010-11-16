require "hapi"
require "optparse"

class Hapi::Command < Hapi::Common
  class << self
    def run
      parse_options
    end

    def parse_options
      @options = {}

      OptionParser.new do |opts|
        opts.banner = <<-EOB

Usage: hapi [opts] commands [job_name]

  Commands:
  +build+::   start a job building.
  +list+::    list jobs. [job_name used as filter].
  +config+::  pretty print job config. job_name

        EOB

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

      @command, @job_name = ARGV
    end
  end
end
