require "carrierwave/storage/grandcloud"
require "carrierwave/grandcloud/configuration"
CarrierWave.configure do |config|
  config.storage_engines.merge!({:grandcloud => "CarrierWave::Storage::Grandcloud"})
end
CarrierWave::Uploader::Base.send(:include, CarrierWave::Grandcloud::Configuration)