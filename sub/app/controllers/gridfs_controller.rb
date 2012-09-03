# -*- encoding : utf-8 -*-
require 'mongo'
class GridfsController < ActionController::Metal  
  def serve
    gridfs_path = env["PATH_INFO"].gsub("/uploads/", "")
    begin      
      gridfs_file = Mongo::GridFileSystem.new(Mongoid.database).open(gridfs_path, 'r')
      self.response_body = gridfs_file.read
      self.content_type = gridfs_file.content_type
    rescue => e
      if gridfs_path.starts_with?('topic/cover')
        default_topic_file = "#{Rails.root}/app/assets/images/cover/#{gridfs_path.split('/')[-1].split('_______').join('')}"
        self.response_body = File.read(default_topic_file)
        self.content_type = 'image/jpeg'
        return true
      else
        self.status = '404'
        self.content_type='text/plain'
        self.response_body='404 - File Not Found'
      end
    end
  end
end

