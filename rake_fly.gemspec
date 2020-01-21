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

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'rake_dependencies', '>= 1.6'
  spec.add_dependency 'rake_factory', '>= 0.11'
  spec.add_dependency 'ruby_fly', '~> 0.11'
  spec.add_dependency 'semantic', '~> 1.6.1'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'gem-release', '~> 2.0'
  spec.add_development_dependency 'activesupport', '~> 5.2'
  spec.add_development_dependency 'fakefs', '~> 0.18'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
