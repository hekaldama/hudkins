require 'minitest/unit'
require "mocha"
require "ruby-debug"
MiniTest::Unit.autorun


class MiniTest::Unit::TestCase
  def mock_config
  <<-EOXML
<?xml version="1.0" encoding="UTF-8"?><project>
<actions/>
<description/>
<keepDependencies>false</keepDependencies>
<properties/>
<scm class="hudson.scm.SubversionSCM">
<locations>
<hudson.scm.SubversionSCM_-ModuleLocation>
<remote>https://subversion/project_name/branches/current_branch</remote>
<local>.</local>
</hudson.scm.SubversionSCM_-ModuleLocation>
</locations>
<useUpdate>true</useUpdate>
<doRevert>false</doRevert>
<excludedRegions/>
<includedRegions/>
<excludedUsers/>
<excludedRevprop/>
<excludedCommitMessages/>
</scm>
<canRoam>true</canRoam>
<disabled>true</disabled>
<blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
<triggers class="vector"/>
<concurrentBuild>false</concurrentBuild>
<builders/>
<publishers/>
<buildWrappers/>
</project>
  EOXML
  end

  def mock_jobs
  <<-EOJSON
  {"assignedLabels":[{}],
  "mode":"NORMAL",
  "nodeDescription":"the master Hudson node",
  "nodeName":"",
  "numExecutors":2,
  "description":null,
  "jobs":[
  {"name":"project_name",
  "url":"http://example.com/job/project_name/",
  "color":"blue"},
  {"name":"project_name2",
  "url":"http://example.com/job/project_name2/",
  "color":"blue"}],
  "overallLoad":{},
  "primaryView":{"name":"All",
  "url":"http://example.com/"},
  "slaveAgentPort":0,
  "useCrumbs":false,
  "useSecurity":false,
  "views":[{"name":"All",
  "url":"http://example.com/"}]}
  EOJSON
  end
end
