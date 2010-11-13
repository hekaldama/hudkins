require "test/test_helper"
require "hapi"

class TestHapiJob < MiniTest::Unit::TestCase
  def setup
    @host = "http://hudson.int.atti.com"
    @data = {"name"=>"project_name", "url"=>"http://example.com/job/project_name/", "color"=>"blue"}
    @hud = Hapi.new @host
    @hud.expects(:get).at_least_once.with("/api/json").returns( mock_jobs )
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

  def test_scm_update
    @hud.expects(:get).at_least_once.with( "/job/project_name/" + "/config.xml").returns( mock_config )
    old_url = @job.scm_url
    new_url = "http://svn/foobar"
    @hud.expects(:post).with( @job.path + "/config.xml", anything )
    @job.scm_url = new_url
    new_config = @job.config
    @hud.expects(:get).with( "/job/project_name/" + "/config.xml").returns( new_config.to_s )
    ret = @job.update_scm!
    assert_equal new_url, ret
  end
end
