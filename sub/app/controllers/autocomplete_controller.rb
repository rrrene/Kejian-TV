# -*- encoding : utf-8 -*-
class AutocompleteController < ApplicationController
  skip_filter :set_vars
  skip_filter :xookie

  def swords
    result = Redis::Search.query("Courseware",params[:term],:limit=>10,:sort_field=>'c')
    result += Redis::Search.complete("Courseware",params[:term],:limit=>10,:sort_field=>'c') if result.length < 10
    #todo teacher
    render json:result
  end
  def all
    q=CGI::unescape(params[:q].xi)
    render json:({}.tap do |ret|
      ret['Courseware'] = Redis::Search.query("Courseware",q,:limit=>4,:sort_field=>'score')
      ret.delete('Courseware') if ret['Courseware'].blank?
      ret['Department'] = Redis::Search.query("Department",q,:limit=>3,:sort_field=>'coursewares_count')
      ret['Department'] += Redis::Search.query("Department",q,:sort_field=>'coursewares_count') if ret['Department'].size<3
      ret['Department'] = ret['Department'].uniq.limit(3)
      ret.delete('Department') if ret['Department'].blank?
      ret['Teacher'] = Redis::Search.query("Teacher",q,:limit=>3,:sort_field=>'coursewares_count')
      ret['Teacher'] += Redis::Search.query("Teacher",q,:sort_field=>'coursewares_count') if ret['Teacher'].size<3
      ret['Teacher'] = ret['Teacher'].uniq.limit(3)
      ret.delete('Teacher') if ret['Teacher'].blank?
      ret['Course'] = Redis::Search.query("Course",q,:limit=>3,:sort_field=>'coursewares_count')
      ret['Course'] += Redis::Search.query("Course",q,:sort_field=>'coursewares_count') if ret['Course'].size<3
      ret['Course'] = ret['Course'].uniq.limit(3)
      ret.delete('Course') if ret['Course'].blank?
      ret['User'] = Redis::Search.query("User",q,:limit=>3,:sort_field=>'coursewares_count')
      ret['User'] += Redis::Search.query("User",q,:sort_field=>'followers_count') if ret['User'].size<3
      ret['User'] = ret['User'].uniq.limit(3)
      ret.delete('User') if ret['User'].blank?
      ret['final']=q
    end)
  end
  private
  def psvr_uniq(arr)
  end
end
