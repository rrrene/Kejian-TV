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
    render json:({}.tap do |ret|
      ret['Courseware']=[]
      ret['Course']=[]
      ret['Department']=[]
      ret['Teacher']=[]
      ret['User']=[]
    end)
  end
end
