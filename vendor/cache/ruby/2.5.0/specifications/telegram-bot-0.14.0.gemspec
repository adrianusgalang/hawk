# -*- encoding: utf-8 -*-
# stub: telegram-bot 0.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "telegram-bot".freeze
  s.version = "0.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Max Melentiev".freeze]
  s.bindir = "exe".freeze
  s.date = "2018-06-07"
  s.email = ["melentievm@gmail.com".freeze]
  s.homepage = "https://github.com/telegram-bot-rb/telegram-bot".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "Breaking changes in v0.14! See upgrade guide at https://github.com/telegram-bot-rb/telegram-bot/wiki/Upgrading-to-0.14".freeze
  s.required_ruby_version = Gem::Requirement.new("~> 2.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Library for building Telegram Bots with Rails integration".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionpack>.freeze, ["< 6.0", ">= 4.0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, ["< 6.0", ">= 4.0"])
      s.add_runtime_dependency(%q<httpclient>.freeze, ["~> 2.7"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.16"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    else
      s.add_dependency(%q<actionpack>.freeze, ["< 6.0", ">= 4.0"])
      s.add_dependency(%q<activesupport>.freeze, ["< 6.0", ">= 4.0"])
      s.add_dependency(%q<httpclient>.freeze, ["~> 2.7"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<actionpack>.freeze, ["< 6.0", ">= 4.0"])
    s.add_dependency(%q<activesupport>.freeze, ["< 6.0", ">= 4.0"])
    s.add_dependency(%q<httpclient>.freeze, ["~> 2.7"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
