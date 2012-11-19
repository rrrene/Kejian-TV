# -*- encoding : utf-8 -*-
require "test_helper"

describe UcenterController do
  it "确保/api/uc的可用状态" do
    get :ktv_uc_client,code:UCenter::Php.authcode("action=test&time=#{Time.now.to_i}",'ENCODE',UCenter.getdef('UC_KEY'))
    assert UcenterController::API_RETURN_SUCCEED==@response.body,"确保/api/uc的可用状态 - test"
  end
end
