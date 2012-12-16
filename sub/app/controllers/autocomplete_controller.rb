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
    q=CGI::unescape(params[:q]).xi
    @liber_terms = PinyinSplit.split(q.gsub(/[^\w]/,'').downcase)
    @fenci_terms = Redis::Search.split(q).collect{|x| x.force_encoding('utf-8')}
    @spetial_symbols=q.scan(/[-+#]+/).to_a
    render json:({}.tap do |ret|
      if !params[:only]
        ret['Courseware'] = Courseware.psvr_redis_search(q,@liber_terms,4)
        ret.delete('Courseware') if ret['Courseware'].blank?

        ret['PlayList'] = Redis::Search.query("PlayList",q,:limit=>4,:sort_field=>'score')
        ret['PlayList'] += Redis::Search.query("PlayList",@liber_terms,:limit=>4,:sort_field=>'score') if ret['PlayList'].size<4
        ret['PlayList'] = ret['PlayList'].psvr_uniq.limit(4)
        ret.delete('PlayList') if ret['PlayList'].blank?

        ret['Department'] = Redis::Search.query("Department",q,:limit=>3,:sort_field=>'coursewares_count')
        ret['Department'] += Redis::Search.complete("Department",q,:limit=>3,:sort_field=>'coursewares_count') if ret['Department'].size<3
        ret['Department'] += Redis::Search.query("Department",@liber_terms,:limit=>3,:sort_field=>'coursewares_count') if ret['Department'].size<3
        ret['Department'] += Redis::Search.complete("Department",@liber_terms,:limit=>3,:sort_field=>'coursewares_count') if ret['Department'].size<3
        ret['Department'] = ret['Department'].psvr_uniq.limit(3)
        ret.delete('Department') if ret['Department'].blank?

        ret['Teacher'] = Redis::Search.query("Teacher",q,:limit=>3,:sort_field=>'coursewares_count')
        ret['Teacher'] += Redis::Search.complete("Teacher",q,:limit=>3,:sort_field=>'coursewares_count') if ret['Teacher'].size<3
        ret['Teacher'] += Redis::Search.query("Teacher",@liber_terms,:limit=>3,:sort_field=>'coursewares_count') if ret['Teacher'].size<3
        ret['Teacher'] += Redis::Search.complete("Teacher",@liber_terms,:limit=>3,:sort_field=>'coursewares_count') if ret['Teacher'].size<3
        ret['Teacher'] = ret['Teacher'].psvr_uniq.limit(3)
        ret.delete('Teacher') if ret['Teacher'].blank?        
      end
      courses_lim = params[:only] ? 12 : 3;
      ret['Course'] = Redis::Search.query("Course",q,:limit=>courses_lim,:sort_field=>'coursewares_count')
      ret['Course'] += Redis::Search.complete("Course",q,:limit=>courses_lim,:sort_field=>'coursewares_count') if ret['Course'].size<courses_lim
      ret['Course'] += Redis::Search.query("Course",@liber_terms,:limit=>courses_lim,:sort_field=>'coursewares_count') if ret['Course'].size<courses_lim
      ret['Course'] += Redis::Search.complete("Course",@liber_terms,:limit=>courses_lim,:sort_field=>'coursewares_count') if ret['Course'].size<courses_lim
      ret['Course'] = ret['Course'].psvr_uniq.limit(courses_lim)
      ret.delete('Course') if ret['Course'].blank?
      if !params[:only]
        ret['User'] = Redis::Search.query("User",q,:limit=>3,:sort_field=>'coursewares_count')
        ret['User'] += Redis::Search.complete("User",q,:limit=>3,:sort_field=>'followers_count') if ret['User'].size<3
        ret['User'] += Redis::Search.query("User",@liber_terms,:limit=>3,:sort_field=>'followers_count') if ret['User'].size<3
        ret['User'] += Redis::Search.complete("User",@liber_terms,:limit=>3,:sort_field=>'followers_count') if ret['User'].size<3
        ret['User'] = ret['User'].psvr_uniq.limit(3)
        ret.delete('User') if ret['User'].blank?
      end
      p @final_term=(@liber_terms.split(/\s+/)+@fenci_terms+@spetial_symbols).uniq
      ret['final']=@final_term
    end)
  end
end
