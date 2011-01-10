= hapi

* http://github.com/bhenderson/hapi

== DESCRIPTION:

Hudson interaction gem.

== FEATURES/PROBLEMS:

=== Implemented:
* Create new job

=== Unimplemented:
* Copy job
* Build Que

* Hudson returns incorrect mime types!!! I've hacked it by setting response.type to the :accept header. This needs to be extracted out to dry up the code

== SYNOPSIS:

See Hapi class documentation.
  hud = Hapi.new "http://example.com"
  hud.jobs # => Hapi::Jobs

=== Working with Jobs

  job = hud.jobs.find_by_name "project-main"
  job.scm_url # => "https://subversion/project/branches/1.1"
  job.scm_url = "https://subversion/project/branches/1.2"
  job.post_config! # => Hapi::Response
  job.build!

=== Creating new jobs
  new_job = hud.add_job new_project_name
  new_job.disabled? # => true
  new_job.scm_url # => nil
  new_job.scm_use :git/:svn, "http://svn/my_cool_repo/new_project_name/trunk"

  job = hud.jobs.find_by_name :job_name
  job2 = job.copy new_name ||
         hud.copy_job job, new_name
  job2.scm_url = "http://svn/new/url"
  job2.post_config!


== REQUIREMENTS:

* heavily built ontop of "https://github.com/archiloque/rest-client"
* see link:Rakefile

== INSTALL:

* git clone http://github.com/bhenderson/hapi.git
* cd hapi/
* rake package
* gem install pkg/hapi.gem

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(The MIT License)

Copyright (c) 2011

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
