# -*- encoding : utf-8 -*-

class MineController < ApplicationController
  def index
    @seo[:title] = "我的课件"
    
    respond_to do |format|
      format.json{
        render "index"
      }
      format.html{
        pagination_get_ready
        @coursewares = Courseware.where(:user_id => current_user._id).order(:created_at.desc)
        pagination_over(@coursewares.count)
        @courseware = @coursewares.paginate(:page => @page, :per_page => @per_page)
        
        render "index"
      }
    end
  end
  

  def delete
      params[:kj_ids].split(',').each do |i| 
                  if(!i.empty?)
                        Courseware.find(i.to_s).delete
                  end
      end

  end
end
