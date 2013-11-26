# -*- encoding : utf-8 -*-
module UCenter
  module IBeike
    %w{
      login
      get_user
    }.each do |method_name|
      define_method method_name do |mod,request,opts|
        return UCenter.in_out_ibeike(mod,__method__.to_s,request,opts)
      end
    end
    module_function(*instance_methods)
  end
end
