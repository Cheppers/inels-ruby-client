# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'inels'
  spec.version       = '0.3.0'
  spec.authors       = ['Cheppers developers']
  spec.email         = ['info@cheppers.com']

  spec.required_ruby_version = '~> 2.3'

  spec.summary       = 'Inels client library'
  spec.description   = 'Client library for the Inels eLAN-RF-003 home '\
                       'automation system.'
  spec.homepage      = 'https://github.com/cheppers/inels'

  spec.files = Dir['lib/**/*']
  spec.executables << 'inels'

  spec.require_paths = ['lib']

  spec.add_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_dependency 'parallel', '~> 1.12'
  spec.add_dependency 'rest-client', '~> 2.0'
  spec.add_dependency 'terminal-table', '~> 1.8.0'
  spec.add_dependency 'thor', '~> 0.20'

  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rubocop', '~> 0.60'
end
