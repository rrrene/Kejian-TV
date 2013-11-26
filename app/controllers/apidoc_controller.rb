# -*- encoding : utf-8 -*-
class ApidocController < ApplicationController
  def index
  end
  def show_page
    render params[:page]
  end
end
