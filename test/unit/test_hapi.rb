require "test/test_helper"
require "hapi"

class TestHapi < MiniTest::Unit::TestCase
  def setup
    @host = "http://hudson.int.atti.com"
    @hud = Hapi.new @host
    @hud.expects(:get).at_least_once.with("/api/json").returns( mock_jobs )
    @hud.jobs
  end

  #def test_setup_proc
    #refute Hapi.const_defined? "SETUP_PROC"
    #Hapi.setup do
      #"this is a block!"
    #end
    #assert_kind_of Proc, Hapi::SETUP_PROC
  #end

  def test_object_inspect
    s = Hapi.object_inspect self, "foobar"
    assert_kind_of String, s
    assert_match /foobar/, s
  end

  def test_new
    assert_equal @host, @hud.host
  end

  def test_jobs
    # already initialized.
    Hapi::Jobs.expects(:new).never
    @hud.jobs
  end

  def test_update_jobs
    Hapi::Jobs.expects(:new).once
    @hud.update_jobs
  end

  def test_get
    RestClient::Resource.any_instance.expects(:get).once.returns( "path/info" )
    assert Hapi.new.get( "/my/path" ), "hapi.get should return true"
    assert_raises ArgumentError do 
      Hapi.new.get
    end
  end

  def test_get_with_invalid_path
    RestClient::Resource.any_instance.expects(:get).with( "/invalid/path", @hud.send(:get_default_options) ).raises( RestClient::ResourceNotFound )
    @hud.get "/invalid/path" 
    #assert_raises RestClient::ResourceNotFound do
      #Hapi.new.get "/invalid/path"
    #end
  end

  def test_parse_body_json
    ret = @hud.parse_body mock_jobs
    assert_kind_of Hash, ret
    assert_equal "http://example.com/job/project_name/", ret["jobs"].first["url"]
  end

  def test_parse_body_xml
    ret = @hud.parse_body mock_config
    assert_kind_of Nokogiri::XML::Document, ret
    assert_equal "https://subversion/project_name/branches/current_branch", ret.at("//scm//remote").content
  end

  def test_post
    RestClient::Resource.any_instance.expects(:post).once
    @hud.post "/my/path", "data"
  end

  def test_post_failure
    RestClient::Resource.any_instance.expects(:post).once.raises( RestClient::Exception.new )
    assert_raises RestClient::Exception do 
      @hud.post "/my/path", "bad_data"
    end
  end

end
