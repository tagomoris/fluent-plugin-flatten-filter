# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-flatten-filter"
  spec.version       = "0.0.1"
  spec.authors       = ["TAGOMORI Satoshi"]
  spec.email         = ["tagomoris@gmail.com"]
  spec.description   = %q{Plugin to flatten into single record}
  spec.summary       = %q{Fluentd plugin to flatten hashes and arrays recursively}
  spec.homepage      = "https://github.com/tagomoris/fluent-plugin-flatten-filter"
  spec.license       = "APLv2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
