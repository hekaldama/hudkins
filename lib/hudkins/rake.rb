require "rubygems"
require "rest_client"
require "json"
#require "active_record"
require "nokogiri"

$: << File.join( File.dirname( __FILE__ ), ".." )
require 'hudkins'

# Load our rakefile extensions
Dir["#{File.dirname(__FILE__)}/../tasks/**/*.rake"].sort.each { |ext| load ext }

##
# rake hudkins:update job=rservices-m
#
# rake hudkins:update_main
# rake hudkins:update_release_candidate
# rake hudkins:update_in_production
#
# rake hudkins:update:rservices_main
