if ENV['CI'] || ENV['COVERAGE']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end
