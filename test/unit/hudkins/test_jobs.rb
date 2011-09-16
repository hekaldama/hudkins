require "test/test_helper"
require "hudkins"

class TestHudkinsJobs < MiniTest::Unit::TestCase
  def setup
    hudkins_setup
    @jobs = @hud.jobs
  end

  def test_new
    assert_kind_of Hudkins::Jobs, @jobs
    assert_kind_of Enumerable, @jobs, "must extend enumerable."
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
end

