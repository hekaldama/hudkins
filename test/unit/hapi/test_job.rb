require "test/test_helper"
require "hapi"

class TestHapiJob < MiniTest::Unit::TestCase
  def setup
    @data = {"name"=>"project_name", "url"=>"http://example.com/job/project_name/", "color"=>"blue"}
    @host = "http://example.com"
    hapi_setup
    @jobs = @hud.jobs
    @job = @jobs.find_by_name "project_name"
  end

  def test_new
    job = Hapi::Job.new @hud, @data
    assert_equal %q(/job/project_name/), job.path
  end

  def test_sorting
    assert @jobs.each.first < @jobs.each.last, 
      "must respond to sorting methods.\nfirst job's name should be less than second job's name"
  end

  def test_update_config_updates_config_instance_variable
    @job.instance_variable_set "@config", nil
    @hud.expects(:get_parsed).with( @job.path + "/config.xml", optionally(kind_of(Hash)) ).returns( "test/config" )
    @job.update_config
    assert_equal "test/config", @job.instance_variable_get( "@config" )
  end

  def test_config
    mock_rc_resource(:get, mock_files.config, :xml)
    #@hud.expects(:get).once.returns( mock_files.config )
    @job.config
    @job.config
    assert_kind_of Nokogiri::XML::Document, @job.config
  end

  # should we post if @config hasn't changed?
  # we could set a dirty? flag whenever we update it...

  def test_post_config!
    # make sure we set @config
    @job.stubs(:update_config).returns( "mock/config" )
    @job.config
    @hud.expects(:post).with( @job.path + "/config.xml", "mock/config", optionally(kind_of(Hash)))
    @job.post_config!
  end

  def test_scm_url
    mock_rc_resource(:get, mock_files.config, :xml)
    assert_equal "https://subversion/project_name/branches/current_branch", @job.scm_url
  end

  #def test_scm_update
    #@hud.expects(:get).at_least_once.with( "/job/project_name/" + "/config.xml").returns( mock_config )
    #old_url = @job.scm_url
    #new_url = "http://svn/foobar"
    #@hud.expects(:post).with( @job.path + "/config.xml", anything )
    #@job.scm_url = new_url
    #new_config = @job.config
    #@hud.expects(:get).with( "/job/project_name/" + "/config.xml").returns( new_config.to_s )
    #ret = @job.update_scm!
    #assert_equal new_url, ret
  #end
end
