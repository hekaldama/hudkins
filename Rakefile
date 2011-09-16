# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :isolate

$:.unshift './'

Hoe.spec 'hudkins' do
  developer('Brian Henderson', 'bhenderson@attinteractive.com')

  extra_deps << [ "json",              "~> 1.4.6"]
  extra_deps << [ "nokogiri",          "~> 1.4.3"]
  extra_deps << [ "rest-client",       "~> 1.6.1"]

  extra_dev_deps << [ "minitest",      "~> 1.7.2"]
  extra_dev_deps << [ "mocha",         "~> 0.9.8"]
  #extra_dev_deps << [ "ruby-debug",    "~> 0.10.13"]
end


require "lib/hudkins/rake"

# vim: syntax=ruby
