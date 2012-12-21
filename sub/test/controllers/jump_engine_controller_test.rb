# -*- encoding : utf-8 -*-
require "test_helper"
describe JumpEngineController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  it "url - 游客状态" do
    assert @controller.current_user.nil?
    url = 'https://www.google.com.hk/search?q=jk&oq=jk&aqs=chrome.0.57j60j59j60l2j62.194&sugexp=chrome,mod=17&sourceid=chrome&ie=UTF-8'
    get :url,:url => CGI::escape(url),:sa=>'whatever'
    assert 200==@response.status,'没有或提供错误的sa加密参数，那么导向一个提示页面，是不是要进一步跳转？'
    get :url,:url => CGI::escape(url),:sa => ApplicationHelper.redirect_sa_cal(url)
    assert 302==@response.status,'有正确的sa加密参数，直接跳转'
  end
  it "url" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    url = 'https://www.google.com.hk/search?q=jk&oq=jk&aqs=chrome.0.57j60j59j60l2j62.194&sugexp=chrome,mod=17&sourceid=chrome&ie=UTF-8'
    get :url,:url => CGI::escape(url),:sa=>'whatever'
    assert 200==@response.status,'没有或提供错误的sa加密参数，那么导向一个提示页面，是不是要进一步跳转？'
    get :url,:url => CGI::escape(url),:sa => ApplicationHelper.redirect_sa_cal(url)
    assert 302==@response.status,'有正确的sa加密参数，直接跳转'
  end
end
