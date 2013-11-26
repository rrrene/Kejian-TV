# -*- encoding : utf-8 -*-
class AvatarUploader < BaseUploader
  DZ_SIZES = {
    :small => 48,
    :middle => 120,
    :big => 200
  }

  SIZES = {
    :small => 23,
    :small30 => 30,
    :small32 => 32,
    :small40 => 40,
    :small47 => 47,
    :mid => 50,
    :mid60 => 60,
    :normal => 100,
    :normal180 => 180,
    :huge => 300
  }
  SIZES.each do |key,value|    
    version key do
      process :resize_to_fill => [value,value]
    end
  end  
end
