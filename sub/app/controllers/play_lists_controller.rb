# -*- encoding : utf-8 -*-
class PlayListsController < ApplicationController
  def index
    common_op!
    @seo[:title]='课件锦囊'
    @play_lists = PlayList.no_privacy.normal
    @play_lists = @play_lists.paginate(:page => params[:page], :per_page => @per_page)
  end
end
