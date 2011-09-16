require "test/test_helper"
require "hudkins"

class TestHudkins < MiniTest::Unit::TestCase
  def setup
    @host = "http://example.com"
    @hud = Hudkins.new @host
    @mock_response = mock("response").responds_like(Hudkins::Response.new 1,2,3)
    @mock_response.stubs(:success?).returns(true)
    mock_rc_resource(:get, mock_files.jobs, :json)
    @hud.jobs
  end

  def test_new
    assert_equal @host, @hud.host.to_s
  end

  def test_jobs
    # already initialized.
    Hudkins::Jobs.expects(:new).never
    @hud.jobs
  end

  def test_update_jobs
    Hudkins::Jobs.expects(:new).once
    @hud.update_jobs
  end

  def test_get
    mock_rc_resource(:get)
    assert Hudkins.new.get( "/my/path" ), "hudkins.get should return true"
  end

  def test_get_with_invalid_path
    mock_rc_resource(:get) {|rc| rc.raises( RestClient::ResourceNotFound ) }
    #RestClient::Resource.any_instance.expects(:get).raises( RestClient::ResourceNotFound )
    assert_raises RestClient::ResourceNotFound do
      @hud.get "/invalid/path"
    end
  end

  def test_parse_string_json
    ret = @hud.parse_string mock_files.jobs, :json
    assert_kind_of Hash, ret
    assert_equal "http://example.com/job/project_name/", ret["jobs"].first["url"]
  end

  def test_parse_string_xml
    ret = @hud.parse_string mock_files.config, :xml
    assert_kind_of Nokogiri::XML::Document, ret
    assert_equal "https://subversion/project_name/branches/current_branch", ret.at("//scm//remote").content
  end

  def test_post
    mock_rc_resource(:post)
    @hud.post "/my/path", "data"
  end

  def test_post_failure
    mock_rc_resource(:post) {|rc| rc.raises( RestClient::Exception.new ) }
    assert_raises RestClient::Exception do 
      @hud.post "/my/path", "bad_data"
    end
  end

  #def test_create_new_job
    #mock_rc_resource(:post, mock_files.new_job_json, :xml)
    #job = @hud.add_job :job_name
    #assert_kind_of Hudkins::Job, job
    #assert job.disabled?, "new job must start disabled"
    #assert_nil job.scm_url, "new job must not have any scm_url"
    #assert_equal job, @hud.jobs.find_by_name( :job_name )
  #end
end
