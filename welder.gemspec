Gem::Specification.new do |gem|
  gem.name         = 'welder'
  gem.version      = '0.0.0'
  gem.homepage     = 'http://rubygems.org/gems/welder'
  gem.summary      = 'Welder'
  gem.description  = "Define your application's processes in a simple and powerful way"
  gem.authors      = ['Lorenzo Arribas']
  gem.email        = 'lorenzo.arribas@me.com'
  gem.license      = 'MIT'

  gem.files        = Dir['{lib}/**/*.rb', 'LICENSE', '*.md']
  gem.require_path = 'lib'

  gem.add_development_dependency 'bundler'
end