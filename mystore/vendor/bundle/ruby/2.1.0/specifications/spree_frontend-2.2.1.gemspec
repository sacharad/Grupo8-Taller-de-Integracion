# -*- encoding: utf-8 -*-
# stub: spree_frontend 2.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "spree_frontend"
  s.version = "2.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Sean Schofield"]
  s.date = "2014-03-25"
  s.description = "Required dependency for Spree"
  s.email = "sean@spreecommerce.com"
  s.homepage = "http://spreecommerce.com"
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.requirements = ["none"]
  s.rubyforge_project = "spree_frontend"
  s.rubygems_version = "2.2.2"
  s.summary = "Frontend e-commerce functionality for the Spree project."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree_api>, ["= 2.2.1"])
      s.add_runtime_dependency(%q<spree_core>, ["= 2.2.1"])
      s.add_runtime_dependency(%q<canonical-rails>, ["~> 0.0.4"])
      s.add_runtime_dependency(%q<jquery-rails>, ["~> 3.1.0"])
      s.add_runtime_dependency(%q<stringex>, ["~> 1.5.1"])
      s.add_development_dependency(%q<email_spec>, ["~> 1.2.1"])
      s.add_development_dependency(%q<capybara-accessible>, [">= 0"])
    else
      s.add_dependency(%q<spree_api>, ["= 2.2.1"])
      s.add_dependency(%q<spree_core>, ["= 2.2.1"])
      s.add_dependency(%q<canonical-rails>, ["~> 0.0.4"])
      s.add_dependency(%q<jquery-rails>, ["~> 3.1.0"])
      s.add_dependency(%q<stringex>, ["~> 1.5.1"])
      s.add_dependency(%q<email_spec>, ["~> 1.2.1"])
      s.add_dependency(%q<capybara-accessible>, [">= 0"])
    end
  else
    s.add_dependency(%q<spree_api>, ["= 2.2.1"])
    s.add_dependency(%q<spree_core>, ["= 2.2.1"])
    s.add_dependency(%q<canonical-rails>, ["~> 0.0.4"])
    s.add_dependency(%q<jquery-rails>, ["~> 3.1.0"])
    s.add_dependency(%q<stringex>, ["~> 1.5.1"])
    s.add_dependency(%q<email_spec>, ["~> 1.2.1"])
    s.add_dependency(%q<capybara-accessible>, [">= 0"])
  end
end
