lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "brainstorm_cli/version"

Gem::Specification.new do |spec|
  spec.name          = "brainstorm_cli"
  spec.version       = BrainstormCli::VERSION
  spec.authors       = ["Tom Simmons (Tomboyo)"]
  spec.email         = ["tomasimmons@gmail.com"]

  spec.summary       = "Brainstorm CLI"
  spec.description   = "Brainstorm CLI"
  spec.homepage      = "https://github.com/tomboyo/brainstorm"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  #spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "= 2.0.2"
  spec.add_development_dependency "rake", "= 13.0.0"
  spec.add_development_dependency "minitest", "= 5.12.1"
end
