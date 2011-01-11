require "rubygems"
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

  def hapi_setup
    @host = "http://example.com"
    @hud = Hapi.new @host
    @mock_response = mock("response").responds_like(Hapi::Response.new 1,2,3)
    @mock_response.stubs(:success?).returns(true)
    mock_rc_resource(:get, mock_files.jobs, :json)
    @hud.jobs
  end

  def mock_rc_resource method, body = nil, type = nil
    @mock_response.stubs(:body).returns(body) if body
    @mock_response.stubs(:type).returns(type) if type
    rc_request = RestClient::Request.expects(:execute).with(has_entry(:method => method))
    if block_given?
      yield(rc_request)
    else
      rc_request.returns( @mock_response )
    end
  end


end # MiniTest::Unit::TestCase
