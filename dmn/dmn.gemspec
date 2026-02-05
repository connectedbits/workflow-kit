require_relative "lib/dmn/version"

Gem::Specification.new do |spec|
  spec.name = "dmn"
  spec.version = DMN::VERSION
  spec.authors = ["Connected Bits"]
  spec.email = ["info@connectedbits.com"]

  spec.summary = "A light-weight DMN FEEL expression evaluator and business rule engine in Ruby."
  spec.description = "..."
  spec.homepage    = "https://www.connectedbits.com"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/connectedbits/workflow-kit/feel"

  spec.files = Dir["{lib,doc}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "feel", ">= 0.2.0"

  spec.add_dependency "activemodel", ENV.fetch("RAILS_VERSION", ">= 6.0")
  spec.add_dependency "activesupport", ENV.fetch("RAILS_VERSION", ">= 6.0")
  spec.add_dependency "ostruct"
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
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-doc"
end
