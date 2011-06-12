############################################################################################################
$:.unshift('lib')
require 'rubygems'
require 'rake'
require 'agent_xmpp/config'

#####-------------------------------------------------------------------------------------------------------
task :default => :test

#####-------------------------------------------------------------------------------------------------------
begin
require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "agent_xmpp"
    gem.summary = %Q{Agent XMPP is a ruby XMPP bot framework inspired by web frameworks.}
    gem.email = "troy.stribling@gmail.com"
    gem.homepage = "http://imaginaryproducts.com/projects/agent-xmpp"
    gem.authors = ["Troy Stribling"]
    gem.files.include %w(lib/jeweler/templates/.gitignore VERSION)
    gem.add_dependency('eventmachine',           '>= 0.12.6')
    gem.add_dependency('sequel',                 '>= 3.9.0')
    gem.add_dependency('evma_xmlpushparser',     '>= 0.0.1')
    gem.add_dependency('sqlite3',                '>= 1.3.3')
  end
rescue LoadError
  abort "jeweler is not available. In order to run test, you must: sudo gem install technicalpickles-jeweler --source=http://gems.github.com"
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
  test.libs << ['test/cases', 'test/helpers', 'test/messages']
  test.pattern = 'test/cases/**/test_*.rb'
  test.verbose = true
end

#####-------------------------------------------------------------------------------------------------------
Rake::TestTask.new(:test_case) do |test|
  file = ENV["FILE"] || ''
  test.libs << ['test/cases', 'test/helpers', 'test/messages']
  test.test_files = ["test/cases/#{file}"]
  test.verbose = true
end

#####-------------------------------------------------------------------------------------------------------
begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
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

