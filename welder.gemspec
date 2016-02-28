# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'welder/version'

Gem::Specification.new do |gem|
  gem.name         = 'welder'
  gem.version      = Welder::VERSION
  gem.homepage     = 'http://rubygems.org/gems/welder'
  gem.summary      = 'Welder'
  gem.description  = <<-EOF
    Define your application's processes in a simple and powerful way
  EOF

  gem.authors      = ['Lorenzo Arribas']
  gem.email        = 'lorenzo.arribas@me.com'
  gem.license      = 'MIT'

  gem.files        = Dir['{lib}/**/*.rb', 'LICENSE', '*.md']
  gem.require_path = 'lib'
  gem.required_ruby_version = '>= 2.0.0'

  gem.add_development_dependency 'bundler', '~> 1'
end
