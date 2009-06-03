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
     "agent_xmpp.gemspec",
     "bin/agent_xmpp",
     "lib/agent_xmpp.rb",
     "lib/agent_xmpp/app.rb",
     "lib/agent_xmpp/app/boot.rb",
     "lib/agent_xmpp/app/chat_message_body_controller.rb",
     "lib/agent_xmpp/app/controller.rb",
     "lib/agent_xmpp/app/format.rb",
     "lib/agent_xmpp/app/map.rb",
     "lib/agent_xmpp/app/routes.rb",
     "lib/agent_xmpp/app/view.rb",
     "lib/agent_xmpp/client.rb",
     "lib/agent_xmpp/client/client.rb",
     "lib/agent_xmpp/client/connection.rb",
     "lib/agent_xmpp/client/parser.rb",
     "lib/agent_xmpp/patches.rb",
     "lib/agent_xmpp/patches/standard_library_patches.rb",
     "lib/agent_xmpp/patches/standard_library_patches/array.rb",
     "lib/agent_xmpp/patches/standard_library_patches/float.rb",
     "lib/agent_xmpp/patches/standard_library_patches/hash.rb",
     "lib/agent_xmpp/patches/standard_library_patches/object.rb",
     "lib/agent_xmpp/patches/standard_library_patches/string.rb",
     "lib/agent_xmpp/patches/xmpp4r_patches.rb",
     "lib/agent_xmpp/patches/xmpp4r_patches/command.rb",
     "lib/agent_xmpp/patches/xmpp4r_patches/iq.rb",
     "lib/agent_xmpp/patches/xmpp4r_patches/x_data.rb",
     "lib/agent_xmpp/utils.rb",
     "lib/agent_xmpp/utils/logger.rb",
     "lib/agent_xmpp/utils/roster.rb",
     "lib/agent_xmpp/version.rb",
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
      s.add_runtime_dependency(%q<troystribling-evma_xmlpushparser>, ["= 0.0.1"])
      s.add_runtime_dependency(%q<xmpp4r>, ["= 0.4"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.3"])
      s.add_dependency(%q<eventmachine>, ["= 0.12.6"])
      s.add_dependency(%q<troystribling-evma_xmlpushparser>, ["= 0.0.1"])
      s.add_dependency(%q<xmpp4r>, ["= 0.4"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.3"])
    s.add_dependency(%q<eventmachine>, ["= 0.12.6"])
    s.add_dependency(%q<troystribling-evma_xmlpushparser>, ["= 0.0.1"])
    s.add_dependency(%q<xmpp4r>, ["= 0.4"])
  end
end
