# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inels'

Gem::Specification.new do |spec|
  spec.name          = 'inels'
  spec.version       = '0.1.0'
  spec.authors       = ['Zsolt Prontvai']
  spec.email         = ['prozsolt@gmail.com']

  spec.summary       = %q{Inels client library}
  spec.description   = %q{Client library for the Inels eLAN-RF-003 home automation system}
  spec.homepage      = "https://github.com/ProZsolt"

  spec.files = Dir["lib/**/*"]

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rest-client'
end