lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "brainstorm/version"

Gem::Specification.new do |spec|
  spec.name          = "brainstorm"
  spec.version       = Brainstorm::VERSION
  spec.authors       = ["Tom Simmons (Tomboyo)"]
  spec.email         = ["tomasimmons@gmail.com"]
  spec.summary       = "Brainstorm CLI"
  spec.description   = "Brainstorm CLI"
  spec.homepage      = "https://github.com/tomboyo/brainstorm"
  spec.license       = "MIT"
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(unit\-tests/)}) }
      .reject { |f| f.match(%r{^(integration\-tests/)}) }
  end

  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tomlrb", "= 1.2.8"
  spec.add_dependency "http", "= 4.2.0"

  spec.add_development_dependency "bundler", "= 2.0.2"
  spec.add_development_dependency "rake", "= 13.0.0"
  spec.add_development_dependency "minitest", "= 5.12.1"
  spec.add_development_dependency "irb"
end
