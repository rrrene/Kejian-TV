# -*- encoding : utf-8 -*-
require "test_helper"

describe UcenterController do
  it "[[test]]" do
    get :ktv_uc_client,code:UCenter::Php.authcode("action=test&time=#{Time.now.to_i}",'ENCODE',UCenter.getdef('UC_KEY'))
    assert UcenterController::API_RETURN_SUCCEED==@response.body,"确保/api/uc的可用状态 - test"
  end
  it "[[deleteuser]]" do  
  end
  it "[[renameuser]]" do  
  end
  it "[[deletefriend]]" do  
  end
  it "[[gettag]]" do  
  end
  it "[[getcreditsettings]]" do  
  end
  it "[[getcredit]]" do  
  end
  it "[[updatecreditsettings]]" do  
  end
  it "[[updateclient]]" do  
  end
  it "[[updatepw]]" do  
  end
  it "[[updatebadwords]]" do  
  end
  it "[[updatehosts]]" do  
  end
  it "[[updateapps]]" do  
  end
  it "[[updatecredit]]" do  
  end
  it "[[synlogin]]" do  
  end
  it "[[synlogout]]" do  
  end
end
