# -*- encoding : utf-8 -*-
unless Rails.env.development?
  Grim.processor = Grim::MultiProcessor.new([Grim::ImageMagickProcessor.new({:imagemagick_path => "/usr/bin/convert", :ghostscript_path => "/usr/local/bin/gs"})])
#    Grim::ImageMagickProcessor.new({:imagemagick_path => "/usr/local/bin/convert", :ghostscript_path => "/usr/bin/gs"}),
#    Grim::ImageMagickProcessor.new({:imagemagick_path => "/usr/bin/convert", :ghostscript_path => "/usr/local/bin/gs"})
end
