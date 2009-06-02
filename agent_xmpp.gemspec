# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{agent_xmpp}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Troy Stribling"]
  s.date = %q{2009-06-02}
  s.default_executable = %q{agent_xmpp}
  s.email = %q{troy.stribling@gmail.com}
  s.executables = ["agent_xmpp"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/agent_xmpp.rb",
     "test/agent_xmpp_test.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/troystribling/agent_xmpp}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "test/agent_xmpp_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0.8.3"])
      s.add_runtime_dependency(%q<eventmachine>, ["= 0.12.6"])
      s.add_runtime_dependency(%q<troystribling-evma_eventmachine>, ["= 0.0.1"])
      s.add_runtime_dependency(%q<xmpp4r>, ["= 0.4"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.3"])
      s.add_dependency(%q<eventmachine>, ["= 0.12.6"])
      s.add_dependency(%q<troystribling-evma_eventmachine>, ["= 0.0.1"])
      s.add_dependency(%q<xmpp4r>, ["= 0.4"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.3"])
    s.add_dependency(%q<eventmachine>, ["= 0.12.6"])
    s.add_dependency(%q<troystribling-evma_eventmachine>, ["= 0.0.1"])
    s.add_dependency(%q<xmpp4r>, ["= 0.4"])
  end
end
