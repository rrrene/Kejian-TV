# -*- encoding : utf-8 -*-
module Ktv
  # 一些各种类间公用的方法，你懂的 ：）
  class Shared
    # 这是一个异常类 
    # 表示我们的代码需要改进了！ 
    class ScriptNeedImprovementException < NotImplementedError
    end
    
    # 这是一个异常类 
    class LogicNotRight < NotImplementedError
    end
    

    class GodDamnRenrenException < Exception
    end

    # 又是一个异常类
    # 表示用户提供的数据有题
    # 不是我们的题
    class UserDataException < StandardError
    end

    # 我们将在类中开一个Mechanize的派对！
    module MechanizeParty
      extend ActiveSupport::Concern
      included do
        attr_reader :agent
        attr_reader :history
      end
      # introduces @agent and @history variables.
      def initialize(opts={})
        @agent = Mechanize.new
        @agent.log = Ktv.config.logger
        @agent.user_agent = Ktv.config.user_agent
        @agent.open_timeout = Ktv.config.open_timeout
        @agent.read_timeout = Ktv.config.read_timeout
        @agent.idle_timeout = Ktv.config.idle_timeout
        @agent.redirect_ok = :permanent
        @agent.robots = false
        @agent.follow_meta_refresh = true
        @agent.set_proxy(
          Ktv.config.proxy.addr,
          Ktv.config.proxy.port,
          Ktv.config.proxy.user,
          Ktv.config.proxy.pass
        ) if Ktv.config.proxy.present?
        @history = @agent.history
      end
      def site
        @site ||= Site.find_or_create_by(name:self.class.name)
      end
    end
  end
end
