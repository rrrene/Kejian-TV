class ApplicationController < ActionController::Base
  protect_from_forgery
  $cnu_new = Time.new(2012,9,3)
  $cnu_exam = Time.new(2013,1,7)
  $cnu_over = Time.new(2013,1,19)
  before_filter :set_vars
  def set_vars
    @seo = Hash.new('')
    agent = request.env['HTTP_USER_AGENT'].downcase
    @is_bot = (agent.match(/\(.*https?:\/\/.*\)/)!=nil)
    @is_ie = (agent.index('msie')!=nil)
    @is_ie6 = (agent.index('msie 6')!=nil)
    @is_ie7 = (agent.index('msie 7')!=nil)
    @is_ie8 = (agent.index('msie 8')!=nil)
    @is_ie9 = (agent.index('msie 9')!=nil)
    @is_ie10 = (agent.index('msie 10')!=nil)
  end
  
end
