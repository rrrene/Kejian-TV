# CarrierWave for SNDA Cloud Storage

This gem adds support for [SNDA Cloud Storage](http://oss.grandcloud.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/), code base on [carrierwave-aliyun](https://github.com/huacnlee/carrierwave-aliyun)

## Installation

    gem install carrierwave-grandcloud

## Using Bundler

    gem 'sndacs', :git => 'git://github.com/hui/sndacs-ruby.git'
    gem 'carrierwave-grandcloud'

## Configuration

You'll need to configure the to use this in config/initializes/carrierwave.rb

```ruby
CarrierWave.configure do |config|
  config.storage = :grandcloud
  config.grandcloud_access_id = "xxxxxx"
  config.grandcloud_access_key = 'xxxxxx'
  # you need create this bucket first!
  config.grandcloud_bucket = "simple"

  # add this line if your bucket is private
  config.grandcloud_bucket_private = true
end
```