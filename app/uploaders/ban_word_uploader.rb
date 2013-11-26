# -*- encoding : utf-8 -*-
class BanWordUploader < CarrierWave::Uploader::Base
  storage :file
  permissions 0777
  
  def store_dir
    "uploads/"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  def filename
    "words.txt" if original_filename
  end

end
