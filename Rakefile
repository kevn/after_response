require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "after_response"
    gem.summary = %Q{Provides hooks to execute callbacks after the response has been delivered to the client.}
    gem.description = %Q{AfterResponse provides callbacks into the Passenger2 and Passenger3 (and soon, Unicorn)
    request cycle. The main goal is to delay as much non-critical processing until later, delivering
    the response to the client application sooner. This would mainly include logging data into a Mixpanel-like
    service, sending email and other tasks that do not affect the response body in any way.}
    gem.email = "kevin@kev.in"
    gem.homepage = "http://github.com/kevn/after_response"
    gem.authors = ["Kevin E. Hunt"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "after_response #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end