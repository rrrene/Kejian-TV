# -*- encoding : utf-8 -*-
module UCenter
  module Version
    %w{
      check
    }.each do |method_name|
      define_method method_name do |request,opts|
        return UCenter.in_out(self.name.split("::")[-1].underscore,__method__.to_s,request,opts)
      end
    end
    module_function(*instance_methods)
  end
end
