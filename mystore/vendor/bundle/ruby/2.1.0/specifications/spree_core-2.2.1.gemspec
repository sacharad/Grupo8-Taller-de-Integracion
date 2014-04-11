# -*- encoding: utf-8 -*-
# stub: spree_core 2.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "spree_core"
  s.version = "2.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Sean Schofield"]
  s.date = "2014-03-25"
  s.description = "The bare bones necessary for Spree."
  s.email = "sean@spreecommerce.com"
  s.homepage = "http://spreecommerce.com"
  s.licenses = ["BSD-3"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.2.2"
  s.summary = "The bare bones necessary for Spree."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemerchant>, ["~> 1.42.3"])
      s.add_runtime_dependency(%q<acts_as_list>, ["= 0.3.0"])
      s.add_runtime_dependency(%q<awesome_nested_set>, ["~> 3.0.0.rc.3"])
      s.add_runtime_dependency(%q<aws-sdk>, ["= 1.27.0"])
      s.add_runtime_dependency(%q<cancan>, ["~> 1.6.10"])
      s.add_runtime_dependency(%q<deface>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<ffaker>, ["~> 1.16"])
      s.add_runtime_dependency(%q<friendly_id>, ["= 5.0.3"])
      s.add_runtime_dependency(%q<highline>, ["~> 1.6.18"])
      s.add_runtime_dependency(%q<httparty>, ["~> 0.11"])
      s.add_runtime_dependency(%q<json>, ["~> 1.7"])
      s.add_runtime_dependency(%q<kaminari>, ["~> 0.15.0"])
      s.add_runtime_dependency(%q<paperclip>, ["~> 3.4.1"])
      s.add_runtime_dependency(%q<paranoia>, ["~> 2.0"])
      s.add_runtime_dependency(%q<rails>, ["~> 4.0.3"])
      s.add_runtime_dependency(%q<ransack>, ["~> 1.1.0"])
      s.add_runtime_dependency(%q<state_machine>, ["= 1.2.0"])
      s.add_runtime_dependency(%q<stringex>, ["~> 1.5.1"])
      s.add_runtime_dependency(%q<truncate_html>, ["= 0.9.2"])
    else
      s.add_dependency(%q<activemerchant>, ["~> 1.42.3"])
      s.add_dependency(%q<acts_as_list>, ["= 0.3.0"])
      s.add_dependency(%q<awesome_nested_set>, ["~> 3.0.0.rc.3"])
      s.add_dependency(%q<aws-sdk>, ["= 1.27.0"])
      s.add_dependency(%q<cancan>, ["~> 1.6.10"])
      s.add_dependency(%q<deface>, ["~> 1.0.0"])
      s.add_dependency(%q<ffaker>, ["~> 1.16"])
      s.add_dependency(%q<friendly_id>, ["= 5.0.3"])
      s.add_dependency(%q<highline>, ["~> 1.6.18"])
      s.add_dependency(%q<httparty>, ["~> 0.11"])
      s.add_dependency(%q<json>, ["~> 1.7"])
      s.add_dependency(%q<kaminari>, ["~> 0.15.0"])
      s.add_dependency(%q<paperclip>, ["~> 3.4.1"])
      s.add_dependency(%q<paranoia>, ["~> 2.0"])
      s.add_dependency(%q<rails>, ["~> 4.0.3"])
      s.add_dependency(%q<ransack>, ["~> 1.1.0"])
      s.add_dependency(%q<state_machine>, ["= 1.2.0"])
      s.add_dependency(%q<stringex>, ["~> 1.5.1"])
      s.add_dependency(%q<truncate_html>, ["= 0.9.2"])
    end
  else
    s.add_dependency(%q<activemerchant>, ["~> 1.42.3"])
    s.add_dependency(%q<acts_as_list>, ["= 0.3.0"])
    s.add_dependency(%q<awesome_nested_set>, ["~> 3.0.0.rc.3"])
    s.add_dependency(%q<aws-sdk>, ["= 1.27.0"])
    s.add_dependency(%q<cancan>, ["~> 1.6.10"])
    s.add_dependency(%q<deface>, ["~> 1.0.0"])
    s.add_dependency(%q<ffaker>, ["~> 1.16"])
    s.add_dependency(%q<friendly_id>, ["= 5.0.3"])
    s.add_dependency(%q<highline>, ["~> 1.6.18"])
    s.add_dependency(%q<httparty>, ["~> 0.11"])
    s.add_dependency(%q<json>, ["~> 1.7"])
    s.add_dependency(%q<kaminari>, ["~> 0.15.0"])
    s.add_dependency(%q<paperclip>, ["~> 3.4.1"])
    s.add_dependency(%q<paranoia>, ["~> 2.0"])
    s.add_dependency(%q<rails>, ["~> 4.0.3"])
    s.add_dependency(%q<ransack>, ["~> 1.1.0"])
    s.add_dependency(%q<state_machine>, ["= 1.2.0"])
    s.add_dependency(%q<stringex>, ["~> 1.5.1"])
    s.add_dependency(%q<truncate_html>, ["= 0.9.2"])
  end
end
