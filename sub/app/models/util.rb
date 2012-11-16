# -*- encoding : utf-8 -*-
class Util
  class << self
    
    def js_truncate_to(str,lim)
      len=0
      i=0
      while i<str.length
        if str[i].ord>255
          len+=2
        else
          len+=1
        end
        break if len > lim
        i+=1
      end
      return str[0..i-1]
    end


    def js_strlen(str)
      len=0
      i=0
      while i<str.length
        if str[i].ord>255
          len+=2
        else
          len+=1
        end
        i+=1
      end
      return len
    end
    
    def js_chinese(str)
      ret=0
      i=0
      while i<str.length
        if str[i].ord>255
          ret+=1
        end
        i+=1
      end
      return ret
    end
    
    def ws_pp(msg)
      if caller[1] =~ /in `([^`']+)'/
        pp "[WebService]{#{$1}} #{msg}"
      else
        pp "[WebService] #{msg}"
      end
    end
    
    def delComment!
      Comment.be_deleted.each do |item|
        item.logs.delete_all
      end
      Comment.be_deleted.delete_all
    end

    def delAskInvite!
      AskInvite.be_deleted.delete_all
    end

    def delAskSuggestTopic!
      AskSuggestTopic.be_deleted.delete_all
    end

    def delNotification!
      Notification.be_deleted.delete_all
    end

    def delAnswer!
      bad_ids = Answer.be_deleted.collect(&:id)
      bad_id_out_of!(User,:thanked_answer_ids,bad_ids)
      Answer.be_deleted.each do |instance|
        instance.ask.set_first_answer if instance.ask
        instance.ask.save
        instance.comments.delete_all
        instance.logs.delete_all
      end
      Answer.be_deleted.delete_all
    end

    def delTopic!
      bad_ids = Topic.be_deleted.collect(&:id)
      bad_names = Topic.be_deleted.collect(&:name)
      bad_id_out_of!(User,:followed_topic_ids,bad_ids)
      bad_id_out_of!(AskSuggestTopic,:topics,bad_names)
      Topic.be_deleted.each do |instance|
        instance.logs.delete_all
      end
      Topic.be_deleted.delete_all
    end

    def delAsk!
      bad_ids = Ask.be_deleted.collect(&:id)
      bad_id_out_of!(User,:followed_ask_ids,bad_ids)
      bad_id_out_of!(User,:muted_ask_ids,bad_ids)
      bad_id_out_of!(User,:answered_ask_ids,bad_ids)
      del_propogate_to(Answer,:ask_id,bad_ids)
      del_propogate_to(AskInvite,:ask_id,bad_ids)
      del_propogate_to(AskSuggestTopic,:ask_id,bad_ids)
      Ask.be_deleted.each do |instance|
        instance.comments.delete_all
        instance.logs.delete_all
        AskCache.where(:ask_id=>instance.id).delete_all
      end
      Ask.be_deleted.delete_all
    end

    def delUser(opts={})
      if opts[:user_id]
        bad_ids = [opts[:user_id]]
      else
        bad_ids = User.be_deleted.collect(&:id)
      end
      bad_id_out_of!(AskInvite,:invitor_ids,bad_ids)
      bad_id_out_of!(Topic,:follower_ids,bad_ids)
      bad_id_out_of!(Ask,:spam_voter_ids,bad_ids)
      bad_id_out_of!(Ask,:to_user_ids,bad_ids)
      bad_id_out_of!(Ask,:follower_ids,bad_ids)
      bad_id_out_of!(User,:follower_ids,bad_ids)
      bad_id_out_of!(User,:following_ids,bad_ids)
      del_propogate_to(Comment,:user_id,bad_ids)
      del_propogate_to(AskInvite,:user_id,bad_ids)
      del_propogate_to(Notification,:user_id,bad_ids)
      del_propogate_to(Answer,:user_id,bad_ids)
      del_propogate_to(Ask,:to_user_id,bad_ids)
      del_propogate_to(Ask,:user_id,bad_ids)
      User.be_deleted.each do |item|
        item.logs.delete_all
        Answer.where("votes.up"=>item.id).each do |ans|
          ans.votes['up'].delete item.id
          ans.save
        end
        Answer.where("votes.down"=>item.id).each do |ans|
          ans.votes['down'].delete item.id
          ans.save
        end
        item.update_attribute(:banished,"1")
      end
      # User.be_deleted.delete_all
    end


    def bad_id_out_of!(klass,key,bad_ids)
      klass.any_in(key=>bad_ids).each do |u|
        u.update_attribute(key,u.send(key)-bad_ids)
      end
    end

    def del_propogate_to(klass,key,bad_ids)
      ids = []
      klass.where(:deleted.ne=>1).any_in(key=>bad_ids).each do |u|
        u.soft_delete
        ids << u.id
      end
      ids
    end
    
    def integrity_all(opts={})
      delComment!
      delAskInvite!
      delAskSuggestTopic!
      delNotification!
      delAnswer!
      delTopic!
      delAsk!
      delUser(opts)
    end
    
    
  end
end
