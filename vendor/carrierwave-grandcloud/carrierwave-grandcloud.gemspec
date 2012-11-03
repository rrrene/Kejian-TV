# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "carrierwave-grandcloud"
  s.version     = "0.1.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Hui"]
  s.email       = ["hui@networking.io"]
  s.homepage    = "https://github.com/hui/carrierwave-grandcloud"
  s.summary     = %q{SNDA Cloud Storage support for Carrierwave}
  s.description = %q{SNDA Cloud Storage support for Carrierwave}
  s.files         = %w{
    .gitignore
    Gemfile
    Gemfile.lock
    README.md
    carrierwave-grandcloud.gemspec
    lib/carrierwave-grandcloud.rb
    lib/carrierwave/grandcloud/configuration.rb
    lib/carrierwave/storage/grandcloud.rb
    spec/foo.gif
    spec/foo.jpg
    spec/spec_helper.rb
    spec/upload_spec.rb
  }
  s.require_paths = ["lib"]

  s.add_dependency "carrierwave", [">= 0.5.7"]
  s.add_dependency "sndacs", [">= 0.1.0"]
  s.add_development_dependency "rspec", ["~> 2.6"]
  s.add_development_dependency "rake", ["~> 0.9"]
end
