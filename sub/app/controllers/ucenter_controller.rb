# coding: utf-8
class UcenterController < ApplicationController
  skip_before_filter :verify_authenticity_token
  API_RETURN_SUCCEED = '1'
  # -- psvr sep --
  API_DELETEUSER = 1
  API_RENAMEUSER = 1
  API_GETTAG = 1
  API_SYNLOGIN = 1
  API_SYNLOGOUT = 1
  API_UPDATEPW = 1
  API_UPDATEBADWORDS = 1
  API_UPDATEHOSTS = 1
  API_UPDATEAPPS = 1
  API_UPDATECLIENT = 1
  API_UPDATECREDIT = 1
  API_GETCREDIT = 1
  API_GETCREDITSETTINGS = 1
  API_UPDATECREDITSETTINGS = 1
  API_ADDFEED = 1
  API_RETURN_FAILED = '-1'
  API_RETURN_FORBIDDEN = '1'
  # --------------
  def ktv_uc_client
    @get = {}
    code = params[:code]
    decoded = UCenter::Php.authcode(code,'DECODE',UCenter.getdef('UC_KEY'))
    UCenter::Php.parse_str(decoded,@get)
  	if(UCenter::Php.time() - @get['time'].to_i > 3600)
  		render text:'Authracation has expiried'
  		return
  	end
  	if(@get.blank?)
  		render text:'Invalid Request'
  		return
  	end
  	post_str = request.body.read
  	@post = Hash.from_xml(post_str) if post_str.present?
  	puts "[[[#{@get['action']}]]]"
  	pp(@post) if @post.present?
    send(@get['action'])
  end
  
  def test
    render text:API_RETURN_SUCCEED
  end
  def deleteuser
    binding.pry
  end
  def renameuser
    binding.pry
  end
  def deletefriend
    binding.pry
  end
  def gettag
    binding.pry
  end
  def getcreditsettings
    binding.pry
  end
  def getcredit
    binding.pry
  end
  def updatecreditsettings
    binding.pry
  end
  def updateclient
    binding.pry
  end
  def updatepw
    binding.pry
  end
  def updatebadwords
    binding.pry
  end
  def updatehosts
    binding.pry
  end
  def updateapps
    @post['root']['item'].each do |app|
      inst = PsvrApp.find_or_create_by(mysql_id:app['id'])
      inst.update_attribute(:item,app['item'])
    end
    render text:API_RETURN_SUCCEED
  end
  def updatecredit
    binding.pry
  end
  def synlogin
    # the job is done by xookie
    render text:API_RETURN_SUCCEED
  end
  def synlogout
    sign_out_others
    sign_out
    render text:API_RETURN_SUCCEED
  end
end
