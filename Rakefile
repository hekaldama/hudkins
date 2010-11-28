# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :isolate

Hoe.spec 'hapi' do
  developer('Brian Henderson', 'bhenderson@attinteractive.com')

  extra_deps << [ "json",              "~> 1.4.6"]
  extra_deps << [ "nokogiri",          "~> 1.4.3"]
  #extra_deps << [ "optparse"         , "~> "]
  extra_deps << [ "rest_client"      , "~> "]
  #extra_deps << [ "yaml"             , "~> "]

  extra_dev_deps << [ "minitest",      "~> 1.7.2"]
  extra_dev_deps << [ "mocha",         "~> 0.9.8"]
  #extra_dev_deps << [ "ostruct"      , "~> "]
  #extra_dev_deps << [ "ruby-debug"   , "~> "]
end


require "lib/hapi/rake"

# vim: syntax=ruby
