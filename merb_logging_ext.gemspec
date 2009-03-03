# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{merb_logging_ext}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yukiko Kawamoto"]
  s.date = %q{2009-03-03}
  s.description = %q{Merb plugin that provides logging extensions especially when request handling}
  s.email = %q{yu0420@gmail.com}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "lib/merb_logging_ext", "lib/merb_logging_ext/logging_ext.rb", "lib/merb_logging_ext/merbtasks.rb", "lib/merb_logging_ext.rb", "spec/fixture", "spec/fixture/app", "spec/fixture/app/controllers", "spec/fixture/controller.rb", "spec/merb_logging_ext_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/yukiko/merb_logging_ext}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Merb plugin that provides logging extensions especially when request handling}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb>, [">= 1.0.9"])
    else
      s.add_dependency(%q<merb>, [">= 1.0.9"])
    end
  else
    s.add_dependency(%q<merb>, [">= 1.0.9"])
  end
end
