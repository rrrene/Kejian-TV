# -*- encoding : utf-8 -*-
class AnswersController < ApplicationController
  before_filter :require_user_text,:except=>[:show]
    layout 'for_help'

  def up_voter_links arg
  end
  def show
    @answer = Answer.find(params[:id])
    render 'show.mobile',layout:'application.mobile'
  end
  
  def vote
    answer = Answer.find(params[:id])
    vote_type = :down
    if params[:inc] == "1"
      vote_type = :up
    end
    success = answer.vote(:voter_id => current_user.id, :value => vote_type)
    # Note: this logic should be in model
    if answer.up_voters(User).collect(&:email).include?(current_user.email)
      current_user.inc(:vote_up_count,-1)
    end
    if answer.down_voters(User).collect(&:email).include?(current_user.email)
      current_user.inc(:vote_down_count,-1)
    end
    if :up == vote_type
      current_user.inc(:vote_up_count,1)
      answer.inc(:vote_up_count,1)
    else
      current_user.inc(:vote_down_count,1)
      answer.inc(:vote_down_count,1)
    end
    
    if params[:inc] == "1"
      begin
        current_user.inc(:vote_up_count,1)
        log = UserLog.new
        log.user_id = current_user.id
        log.target_id = answer.id
        log.action = "AGREE"
        log.target_parent_id = answer.ask.id
        log.target_parent_title = answer.ask.title
        log.diff = ""
        log.save!
      rescue Exception => e
        p e
      end
    else
      current_user.inc(:vote_down_count,1)
    end
    
    answer.reload
    @answer = answer
    headers['Cache-Control'] = 'NO-CACHE'
    headers['Content-Type'] = 'text/plain; charset=utf-8'
    render :layout=>false
  end

  def spam
    @answer = Answer.find(params[:id])
    size = 1
    if(current_user and current_user.admin?)
      size = Setting.answer_spam_max
    end
    count = @answer.spam(current_user.id,size)
    render :text => count
  end

  def thank
    @answer = Answer.find(params[:id])
    current_user.inc(:thank_count,1)
    @answer.user.inc(:thanked_count,1)
    @answer.inc(:thanked_count,1)
    current_user.thank_answer(@answer)
    render :text => "1"
  end
  
end
