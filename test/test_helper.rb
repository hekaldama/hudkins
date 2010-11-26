require 'minitest/unit'
require "mocha"
require "ruby-debug"
require "ostruct"
require "erb"
MiniTest::Unit.autorun


class MiniTest::Unit::TestCase

  # minitest probably already has a fixtures something. but I don't have access
  # to the docs currently.
  # mock_files.config # => test/fixtures/config.erb
  def mock_files
    @mock_files ||= begin
      obj = OpenStruct.new
      glob = File.join( File.dirname(__FILE__), "fixtures", "*.erb")
      files = Dir.glob( glob )
      files.each do |file|
        name = File.basename( file, ".erb" ).gsub(/\.-/, "_")
        result = File.read( file )
        content = ERB.new(result, 0, "%<>").result(binding)
        obj.send "#{name}=", content # ruby is pretty amazing!
      end
      obj
    end
  end # mock_files

end # MiniTest::Unit::TestCase
