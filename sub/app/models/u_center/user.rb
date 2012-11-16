# -*- encoding : utf-8 -*-
module UCenter
  module User
    UCenter.define('UC_USER_CHECK_USERNAME_FAILED', -1);
    UCenter.define('UC_USER_USERNAME_BADWORD', -2);
    UCenter.define('UC_USER_USERNAME_EXISTS', -3);
    UCenter.define('UC_USER_EMAIL_FORMAT_ILLEGAL', -4);
    UCenter.define('UC_USER_EMAIL_ACCESS_ILLEGAL', -5);
    UCenter.define('UC_USER_EMAIL_EXISTS', -6);
    def get_user(request,opts={})
      return UCenter.in_out(self.name.split("::")[-1].underscore,__method__.to_s,request,opts)
    end
    def rectavatar(request,opts={},extra_cargo={})
      return UCenter.in_out(self.name.split("::")[-1].underscore,__method__.to_s,request,opts,extra_cargo)
    end
    %w{
      synlogin
      synlogout
      register
      update
      edit
      login
      check_email
      check_username
      getprotected
      delete
      deleteavatar
      addprotected
      deleteprotected
      merge
      merge_remove
      getcredit
      uploadavatar
      update_fangwendizhi
      get_fangwendizhi
    }.each do |method_name|
      define_method method_name do |request,opts={}|
        return UCenter.in_out(self.name.split("::")[-1].underscore,__method__.to_s,request,opts)
      end
    end
    module_function(*instance_methods)
  end
end 

