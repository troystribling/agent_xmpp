############################################################################################################
$:.unshift('lib')
require 'rubygems'
require 'rake'
require 'agent_xmpp'

#####-------------------------------------------------------------------------------------------------------
task :default => :test

#####-------------------------------------------------------------------------------------------------------
begin
require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "agent_xmpp"
    gem.summary = %Q{Agent XMPP is a ruby XMPP bot framework inspired by MVC web frameworks.}
    gem.email = "troy.stribling@gmail.com"
    gem.homepage = "http://github.com/troystribling/agent_xmpp"
    gem.authors = ["Troy Stribling"]
    gem.files.include %w(lib/jeweler/templates/.gitignore VERSION)
    gem.add_dependency('rake', '>= 0.8.3')
    gem.add_dependency('eventmachine',                      '= 0.12.6')
    gem.add_dependency('troystribling-evma_xmlpushparser',  '= 0.0.1')
    gem.add_dependency('xmpp4r',                            '= 0.4')
  end
rescue LoadError
  abort "jeweler is not available. In order to run test, you must: sudo gem install technicalpickles-jeweler --source=http://gems.github.com"
end


#####-------------------------------------------------------------------------------------------------------
task :install => :build do
  %x[gem install pkg/agent_xmpp-#{AgentXmpp::VERSION}]
end

#####-------------------------------------------------------------------------------------------------------
task :uninstall do
  %x[gem uninstall agent_xmpp]
end

#####-------------------------------------------------------------------------------------------------------
task :default => [:test]

#####-------------------------------------------------------------------------------------------------------
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << ['test/test_cases', 'test/test_helpers', 'test/test_messages']
  test.pattern = 'test/test_cases/**/test_*.rb'
  test.verbose = true
end

#####-------------------------------------------------------------------------------------------------------
Rake::TestTask.new(:test_case) do |test|
  file = ENV["FILE"] || ''
  test.libs << ['test/test_cases', 'test/test_helpers', 'test/test_messages']
  test.test_files = ["test/test_cases/#{file}"]
  test.verbose = true
end

#####-------------------------------------------------------------------------------------------------------
begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov --source=http://gems.github.com"
  end
end

#####-------------------------------------------------------------------------------------------------------
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "agent_xmpp #{AgentXmpp::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

