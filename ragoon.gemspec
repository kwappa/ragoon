lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ragoon/version'

Gem::Specification.new do |spec|
  spec.name          = 'ragoon'
  spec.version       = Ragoon::VERSION
  spec.authors       = ['SHIOYA, Hiromu']
  spec.email         = ['kwappa.856@gmail.com']

  spec.summary       = 'Ragoon is a simple Garoon 3 API client.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/kwappa/ragoon'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rest-client', '~> 2.0'
  spec.add_dependency 'nokogiri',    '~> 1.7'
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake',    '~> 12.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'test-unit'
end
