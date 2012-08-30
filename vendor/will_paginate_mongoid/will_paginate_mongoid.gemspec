# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "will_paginate_mongoid/version"

Gem::Specification.new do |s|
  s.name        = "will_paginate_mongoid"
  s.version     = WillPaginateMongoid::VERSION
  s.authors     = ["Lucas Souza"]
  s.email       = ["lucasas@gmail.com"]
  s.homepage    = ""
  s.summary     = "An extension that becomes possible use paginate method with Mongoid"
  s.description = ""

  s.rubyforge_project = "will_paginate_mongoid"

  s.files         = %w{
    .gitignore
    .rspec
    Gemfile
    README.md
    Rakefile
    lib/will_paginate_mongoid.rb
    lib/will_paginate_mongoid/engine.rb
    lib/will_paginate_mongoid/mongoid_paginator.rb
    lib/will_paginate_mongoid/version.rb
    spec/fake_app.rb
    spec/integration/mongoid_paginator_spec.rb
    spec/spec_helper.rb
    will_paginate_mongoid.gemspec
  }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "mongoid", "~> 2.4"
  s.add_runtime_dependency "bson_ext", "~> 1.5"
  s.add_runtime_dependency "will_paginate", "~> 3.0.2"
end
