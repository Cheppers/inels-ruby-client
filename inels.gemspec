# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inels'

Gem::Specification.new do |spec|
  spec.name          = 'inels'
  spec.version       = '0.1.0'
  spec.authors       = ['Zsolt Prontvai']
  spec.email         = ['prozsolt@gmail.com']

  spec.summary       = %q{library}
  spec.description   = %q{This tool pulls information from github and jira to make release notes.}
  spec.homepage      = "https://github.com/ProZsolt"

  spec.files = Dir["lib/**/*"]

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_add_runtime_dependency 'rest-client'
end