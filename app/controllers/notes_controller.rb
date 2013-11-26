# -*- encoding : utf-8 -*-
class NotesController < ApplicationController
  before_filter :require_user_js, :only => [:create]
  def create
    @page = params[:note][:page]
    @x = params[:note][:x]
    @y = params[:note][:y]
    @width = params[:note][:width]
    @height = params[:note][:height]
    @body = params[:note][:body]
    @shared = params[:note][:shared]
    @courseware_id = params[:note][:courseware_id]
    
    
    if current_user.user_type==User::FROZEN_USER
      render text:'window.location.href="/frozen_page"'
      return
    end
    
    @note =  Courseware.find(@courseware_id).notes.build
    @note.page = @page
    @note.x = @x
    @note.y = @y
    @note.width = @width
    @note.height = @height
    @note.body = @body
    # @note.shared = @shared
    @note.courseware_id = @courseware_id
    @note.user_id = current_user.id
    if @note.save
      render :text => 'Succeed',:layout => false
    else
      render :text => @note.errors.full_messages.join('，'),:layout => false
    end
  end
  
  def show
    @note = Courseware.find(params[:courseware_id]).notes.find(params[:id])
    @user = User.find(@note.user_id).name
    render :json => { :note => @note.to_json(:only => [:title,:body,:shared,:updated_at]) , :username => @user.to_json}
  end
  
  def edit
    @note = Courseware.find(params[:courseware_id]).notes.find(params[:id])
    @note.body = params[:body]
    if @note.save!
      render :text => 'Succeed',:layout => false
    else
      render :text => 'Failed',:layout => false
    end
  end
  
  def destroy
    @cw =Courseware.find(params[:courseware_id])
    @note = @cw.notes.find(params[:id])
    @note.soft_delete
    redirect_to @cw,:notice=>'笔记被成功删除'
  end
  
end
