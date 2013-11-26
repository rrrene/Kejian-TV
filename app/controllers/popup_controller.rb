# -*- encoding : utf-8 -*-
class PopupController < ApplicationController
  layout "popup"
  def headlines
    @seo[:title] = '一句话描述'
  end
end
