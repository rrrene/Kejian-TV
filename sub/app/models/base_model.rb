# -*- encoding : utf-8 -*-
module BaseModel
  extend ActiveSupport::Concern
  included do
    # 软删除标记，1 表示已经删除，3 表示疑似广告暂时隐藏
    class << self
      attr_accessor :before_soft_delete
      attr_accessor :after_soft_delete
    end
    field :deleted, :type => Integer, :default => 0
    scope :nondeleted, where(:deleted.nin=>[1,3])
    scope :be_deleted, where(:deleted=>1)
    scope :recent, desc("created_at")
  end

  module ClassMethods
    def eager_load(ids)
      res = find(ids)
      ids.map do |id|
        res.detect{|record| record.id.to_s==id.to_s}
      end
    end
    def cache_consultant(child,opts={})
      selfname=self.name.to_s.downcase.pluralize
      opts[:redis_varname] ||= "$redis_#{selfname}"
      opts[:from_what] ||= :id
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.set_#{child}(id,val)
          #{opts[:redis_varname]}.hset(id,:#{child},val)
        end
        def self.get_#{child}(id)
          ret = #{opts[:redis_varname]}.hget(id,:#{child})
          if ret.nil?
            item = #{self.name.to_s}.where(:#{(opts[:from_what] == :id) ? '_id' : opts[:from_what]}=>id).first
            return nil if item.nil? or 1==item.deleted
            ret = item.#{child}
            self.set_#{child}(id,ret)
          end
          ret
        end
      RUBY
      unless opts[:no_callbacks]      
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
            after_save{
              unless 1==self.deleted
                self.class.set_#{child}(self.#{(opts[:from_what] == :id) ? '_id' : opts[:from_what]},self.#{child})
              end
            }
        RUBY
      end
    end
  end
  
  
  def soft_deleted?
    [1,3].include?(self.deleted)
  end
  COMMON_HUMAN_ATTR_NAME = {
    :slug => '友好资源识别号',
    :email => '电子邮箱',
    :created_at => '创建时间',
    :updated_at => '更新时间'
  }
  def view!
    self.inc(:views_count, 1)
  end
  def errors_for_field(field)
    arr = self.errors[field]
    if arr.empty?
      return ''
    else
      return (self.class.human_attribute_name(field) + arr.join('且')).html_safe
    end
  end
  def send_to_msg_center(msg)
    if msg['Receiver'].blank?
      msg['Receiver']=0
    else
      msg['Receiver']=msg['Receiver'].split("\u0000").join('').to_i
    end
    f = File.new(Rails.root+"log/msg_center.log","a")
    f.print "\n---------------------------------------------\n"
    f.print msg.to_json
    f.close
    raise RestClient.post("http://studentcdcapi.kejian.tv/MessageCenter.svc/SendMessage", msg.to_json, :content_type => :json, :accept => :json)
  end
  def normal_deleting_status(current_user=nil)
    return true if current_user and self.respond_to?(:user_id) and current_user.id==self.user_id
    self.deleted.nil? or 0==self.deleted
  end

  def ua(name,value)
    self.update_attribute(name.to_sym,value)
  end

  def soft_delete(async=false)
    ret = self.instance_eval(&self.class.before_soft_delete) unless self.class.before_soft_delete.nil?
    unless false==ret
      self.update_attribute(:deleted,1)
      self.instance_eval(&self.class.after_soft_delete) unless self.class.after_soft_delete.nil?
      if self.respond_to?(:asynchronously_clean_me)
        if async
          Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:asynchronously_clean_me)
        else
          self.asynchronously_clean_me
        end
      end
    end
  end
  def asynchronously_clean_me
    # override me
  end
  # 检测敏感词
  def spam?(attr)
    value = eval("self.#{attr}")
    return false if value.blank?
    if value.class == [].class
      value = value.join(" ")
    end
    m = []
    NaughtyWord.where(:deleted.ne=>1).each do |spam_reg|
      if matched = value.match(Regexp.new(Regexp.escape(spam_reg.word)))
        m << "[#{matched.to_a.join(",")}]"
      end
    end
    if m.empty?
      return false
    else
      self.errors.add(attr,"含有敏感词汇#{m.to_a.join(",")},请您核实后提交！")
    end
  end


  def base_uri(request)
    protocol = request.protocol
    host = request.host_with_port
    name = self.class.name.underscore.pluralize
    id   = self.id.as_json
    uri  = protocol + host + "/" + name + "/" +  id
  end
end

