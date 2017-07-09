# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crossbar-http/version'

Gem::Specification.new do |spec|
  spec.name          = 'crossbar-http'
  spec.version       = Crossbar::HTTP::VERSION
  spec.authors       = ['Eric Chapman']
  spec.email         = ['eric.chappy@gmail.com']

  spec.summary       = %q{Crossbar.io HTTP Bridge Ruby Client}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/ericchapman/ruby-crossbar-http'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.12.0'
  spec.add_development_dependency 'codecov'
end
