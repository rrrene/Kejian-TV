# -*- encoding : utf-8 -*-
class PremiumController < ApplicationController
  def index
    @seo[:title] = "升级用户"
  end
  def plans
    @seo[:title] = "价格明细"
  end
end
