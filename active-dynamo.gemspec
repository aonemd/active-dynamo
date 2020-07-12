# coding: utf-8
require File.expand_path('../lib/active_dynamo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors     = ["Ahmed Saleh"]
  gem.email       = 'aonemdsaleh@gmail.com'
  gem.description = "An ActiveRecord like ODM for AWS DynamoDB"
  gem.summary     = "An ActiveRecord like ODM for AWS DynamoDB"
  gem.homepage    = 'https://github.com/aonemd/active-dynamo'

  gem.files         = `git ls-files`.split($\).reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.name    = 'active-dynamo'
  gem.version = ActiveDynamo::VERSION
  gem.license = 'MIT'

  gem.add_dependency 'aws-sdk'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
end
