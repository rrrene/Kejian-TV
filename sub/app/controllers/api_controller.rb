# -*- encoding : utf-8 -*-
class ApiController < ApplicationController
  layout false
  # before_filter proc{
  # }
  before_filter :oauth_authorized
protected
  def get_ask
    @ask = Ask.where(_id:params[:id]).first
    render {error:'resource not found.'} and return false  if @ask.blank?
  end
  def get_topic
    @topic = Topic.where(name:params[:id]).first
    render json:{error:'Topic not found.'} and return false if @topic.blank?
  end 
  def get_current_user
    @current_user = User.where(slug:params[:as_user]).first if params[:as_user].present?
    @current_user ||= User.where(slug:api_current_user_slug).first if api_current_user_slug.present?
    render json:{error:'Act upon as which user? check `as_user` parameter.'} and return false if @current_user.blank?
  end
  def api_current_user_slug
    ret = nil
    ret = File.basename(@token.resource_owner_uri) if @token.present? 
    ret ||= slug_from_client_id = @current_client.user.slug if @current_client.present?
    ret
  end
  def api_current_user
    User.find_by_slug(api_current_user_slug)
  end
  def api_super_client?
    Setting.trusted_client_ips.include?(request.remote_ip) or request.remote_ip.starts_with?('192.168')
  end
  def render_this!
    the_json = {"size"=>@ret.count,"result"=>@ret}.to_json
    if params[:callback].present?
      meta = headers.dup
      meta['Link'] = @meta_link if @meta_link.present?
      meta = meta.to_json
      render text:" #{params[:callback]}({\"meta\": #{meta},\"data\": #{the_json}})"
    else
      render json: the_json
    end
  end
  def json_body
    body = request.body.read.to_s
    return nil if body.blank?
    begin
      @body = HashWithIndifferentAccess.new(JSON.parse(body))
    rescue => e
      @body = nil
    end
    return @body
  end

  def authenticate
    if api_request
      # oauth_authorized   # uncomment to make all json API protected
    else
      session_auth
    end
  end

  def api_request
    json?
  end

  def json?
    request.format == "application/json"
  end
  
  def oauth_authorized
    action = params[:controller] + "/" + params[:action]
    normalize_token
    normalize_client_id
    @token = OauthToken.where(token: params[:token]).first  # .all_in(scope: [action])
    @current_client = Client.where(uri: params[:client_id]).first
    if (@token.nil? or @token.blocked?) and @current_client.nil?
      render text: "#{request.remote_ip} Unauthorized access.", status: 401
      return false
    else 
      @client_uri = @token ? @token.client_uri : @current_client.uri
      @resource_owner_uri = @token ? @token.resource_owner_uri : "http://kejian.tv/users/#{@current_client.user.slug}"
      access = OauthAccess.find_or_create_by(client_uri: @client_uri , resource_owner_uri: @resource_owner_uri)
      access.accessed!
    end
  end
  
  def must_oauth_authorized
    if @token.nil? or @token.blocked?
      render text: "Unauthorized access." and return
    end
  end

  def normalize_token
    # Token in the body
    if (json_body and @body[:token])
      params[:token] ||= @body[:token]
    end
    # Token in the header
    if request.headers["Authorization"]
      params[:token] ||= request.headers["Authorization"].split(" ").last
    end
  end
  
  def normalize_client_id
    # client_id in the body
    if (json_body and @body[:client_id])
      params[:token] ||= @body[:client_id]
    end
  end
  
  def pagination_get_ready
    params[:page] ||= 1
    params[:per_page] ||= 30
    @page = params[:page].to_i
    @per_page = params[:per_page].to_i
  end
  def pagination_over(sumcount)
    @pages = (sumcount*1.0 / @per_page).ceil
    info_next=info_last=info_first=info_prev=nil
    info_next = "<https://api.kejian.tv#{request.path}?page=#{@page + 1}&per_page=#{@per_page}>; rel=\"next\"" if @page < @pages
    info_last = "<https://api.kejian.tv#{request.path}?page=#{@pages}&per_page=#{@per_page}>; rel=\"last\""
    info_first = "<https://api.kejian.tv#{request.path}?page=1&per_page=#{@per_page}>; rel=\"first\""
    info_prev = "<https://api.kejian.tv#{request.path}?page=#{@page - 1}&per_page=#{@per_page}>; rel=\"prev\"" if @page > 1
    infos=[info_next,info_last,info_first,info_prev].compact
    headers['Link']=infos.join(',')
    @meta_link = infos.collect{|info|
      parts = info.split(';')
      first = parts[0][1..-2]
      if parts[1] =~ /rel="(\w+)"/
        [first,{rel:$1}]
      else
        [first]
      end
    }
  end

  def admin_does_not_exist
    User.admins.first.nil?
  end
end
