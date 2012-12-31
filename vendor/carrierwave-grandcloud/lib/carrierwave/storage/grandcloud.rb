# -*- encoding : utf-8 -*-
require 'carrierwave'
require 'digest/hmac'
require 'digest/md5'
require "sndacs"

module CarrierWave
  module Storage
    class Grandcloud < Abstract
      class File
        def initialize(uploader, base, path)
          @uploader = uploader
          @path = path
          @base = base
        end

        ##
        # Returns the current path/filename of the file on Cloud Files.
        #
        # === Returns
        #
        # [String] A path
        #
        def path
          @path
        end

        ##
        # Reads the contents of the file from Cloud Files
        #
        # === Returns
        #
        # [String] contents of the file
        #
        def read
          object = bucket.objects.find(@path)
          object.content
        end

        ##
        # Remove the file from Cloud Files
        #
        def delete
          begin
            object = bucket.objects.find(@path)
            object.destroy
            true
          rescue Exception => e
            # If the file's not there, don't panic
            nil
          end
        end

        def url(expires_at = Time.now + 3000)
          unless @uploader.grandcloud_bucket_private
            "http://#{Sndacs::REGION_CONTENT_HOST % @uploader.grandcloud_location}/#{@uploader.grandcloud_bucket}/#{path}"
          else
            object = bucket.objects.find(@path)
            if bucket.policy == "Allow"
              object.url
            else
              object.temporary_url(expires_at)
            end
          end
        end

        def store(data)
          new_object = bucket.objects.build(@path)
          new_object.content = data
          new_object.save
        end

        private

          def headers
            @headers ||= {  }
          end

          def bucket
            return $snda_ktv_app
            return @bucket if @bucket
            service = Sndacs::Service.new(:access_key_id => @uploader.grandcloud_access_id,
                              :secret_access_key => @uploader.grandcloud_access_key)
            @bucket = service.bucket(@uploader.grandcloud_bucket, @uploader.grandcloud_location)
            @bucket
          end

      end

      def store!(file)
        f = CarrierWave::Storage::Grandcloud::File.new(uploader, self, uploader.store_path)
        f.store(file.read)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::Grandcloud::File.new(uploader, self, uploader.store_path(identifier))
      end
    end
  end
end
