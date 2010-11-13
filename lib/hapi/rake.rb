require "rubygems"
require "rest_client"
require "json"
#require "active_record"
require "nokogiri"

$: << File.join( File.dirname( __FILE__ ), ".." )
require 'hapi'

# Load our rakefile extensions
Dir["#{File.dirname(__FILE__)}/../tasks/**/*.rake"].sort.each { |ext| load ext }

##
# rake hapi:update job=rservices-m
#
# rake hapi:update_main
# rake hapi:update_release_candidate
# rake hapi:update_in_production
#
# rake hapi:update:rservices_main
