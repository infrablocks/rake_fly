# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_fly/version'

Gem::Specification.new do |spec|
  spec.name = 'rake_fly'
  spec.version = RakeFly::VERSION
  spec.authors = ['Toby Clemson']
  spec.email = ['tobyclemson@gmail.com']

  spec.summary = 'Rake tasks for managing Concourse pipelines.'
  spec.description = 'Rake tasks for common fly interactions allowing ' +
      'Concourse pipelines to be managed as part of a ' +
      'build.'
  spec.homepage = "https://github.com/tobyclemson/rake_fly"
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'gem-release', '~> 0.7'
  spec.add_development_dependency 'activesupport', '~> 4.2'
  spec.add_development_dependency 'fakefs', '~> 0.10'
  spec.add_development_dependency 'simplecov', '~> 0.13'
end
