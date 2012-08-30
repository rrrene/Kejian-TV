# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'voteable_mongo/version'

Gem::Specification.new do |s|
  s.name        = 'voteable_mongo'
  s.version     = VoteableMongo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alex Nguyen']
  s.email       = ['alex@vinova.sg']
  s.homepage    = 'https://github.com/vinova/voteable_mongo'
  s.summary     = %q{Add up / down voting ability to Mongoid and MongoMapper documents}
  s.description = %q{Add up / down voting ability to Mongoid and MongoMapper documents. Optimized for speed by using only ONE request to MongoDB to validate, update, and retrieve updated data.}

  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_development_dependency "mongoid", "~> 2.4"
  s.add_development_dependency 'mongo_mapper', '~> 0.9'
  s.add_development_dependency "bson_ext", "~> 1.5"

  s.rubyforge_project = 'voteable_mongo'

  s.files         = %w{
    .gitignore
    .rvmrc
    .watchr
    CHANGELOG.rdoc
    Gemfile
    README.rdoc
    Rakefile
    TODO
    lib/voteable_mongo.rb
    lib/voteable_mongo/helpers.rb
    lib/voteable_mongo/integrations/mongo_mapper.rb
    lib/voteable_mongo/integrations/mongoid.rb
    lib/voteable_mongo/railtie.rb
    lib/voteable_mongo/railties/database.rake
    lib/voteable_mongo/tasks.rb
    lib/voteable_mongo/version.rb
    lib/voteable_mongo/voteable.rb
    lib/voteable_mongo/voter.rb
    lib/voteable_mongo/voting.rb
    spec/.rspec
    spec/mongo_mapper/models/category.rb
    spec/mongo_mapper/models/comment.rb
    spec/mongo_mapper/models/post.rb
    spec/mongo_mapper/models/user.rb
    spec/mongoid/models/category.rb
    spec/mongoid/models/comment.rb
    spec/mongoid/models/post.rb
    spec/mongoid/models/user.rb
    spec/spec_helper.rb
    spec/voteable_mongo/tasks_spec.rb
    spec/voteable_mongo/voteable_spec.rb
    spec/voteable_mongo/voter_spec.rb
    voteable_mongo.gemspec
  }
  s.require_paths = ['lib']
end
