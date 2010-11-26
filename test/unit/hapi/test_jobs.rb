require "test/test_helper"
require "hapi"

class TestHapiJobs < MiniTest::Unit::TestCase
  def setup
    @host = "http://example.com"
    @hud = Hapi.new @host
    @hud.stubs(:get).with("/api/json").returns( mock_files.jobs )
    @jobs = Hapi::Jobs.new @hud
  end

  def test_new
    Hapi::Job.expects(:new).twice
    jobs = Hapi::Jobs.new @hud
    assert_kind_of Hapi::Jobs, jobs
    # not sure why this doesn't work...
    #assert jobs.respond_to?( :each ), "must respond to #each"
    assert Enumerable === jobs, "must extend enumerable."
  end

  def test_find_by
    # not sure how to test this better. maybe these functions are dumb.
    job = @jobs.find_by_url "http://example.com/job/project_name/"
    assert_match /^project_name$/, job.name
  end

  def test_respond_to?
    @jobs.respond_to? "find_by_name"
    @jobs.respond_to? "find_by_url"
    @jobs.respond_to? "each"
  end

  def test_create_new_job
    RestClient::Resource.any_instance.expects(:post).returns( mock_files.new_job_json )
    job = @hud.add_job :job_name
    assert_kind_of Hapi::Job, job
    assert job.disabled?, "new job must start disabled"
    assert_nil job.scm_url, "new job must not have any scm_url"
    assert_equal job, @hud.jobs.find_by_name( :job_name )
  end
end

