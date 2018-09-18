# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sendmail/version'

Gem::Specification.new do |spec|
  spec.name          = "sendmail"
  spec.version       = Sendmail::VERSION
  spec.authors       = ["Ketan Padegaonkar"]
  spec.email         = ["KetanPadegaonkar@gmail.com"]
  spec.description   = %q{Ruby replacement for sendmail that uses an external smtp server.}
  spec.summary       = %q{Ruby replacement for sendmail that uses an external smtp server.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
