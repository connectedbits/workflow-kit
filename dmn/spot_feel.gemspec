# frozen_string_literal: true

require_relative "lib/spot_feel/version"

Gem::Specification.new do |spec|
  spec.name = "spot_feel"
  spec.version = SpotFeel::VERSION
  spec.authors = ["Connected Bits"]
  spec.email = ["info@connectedbits.com"]

  spec.summary = "A light-weight DMN FEEL expression evaluator and business rule engine in Ruby."
  spec.description = "..."
  spec.homepage    = "https://www.connectedbits.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/connectedbits/feel"

  spec.files = Dir["{lib,doc}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "activemodel", ">= 7.0.2.3"
  spec.add_dependency "activesupport", ">= 7.0.2.3"
  spec.add_dependency "awesome_print", "~> 1.9"
  spec.add_dependency "treetop"
  spec.add_dependency "xmlhasher", "~> 1.0.7"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "minitest-spec"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "solargraph"
  spec.add_development_dependency "treetop"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-doc'
end
