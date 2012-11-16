# -*- encoding : utf-8 -*-
module Ktv
  class Helpers
    # 方便您在子模块中方便地使用Ktv里面的全局config，说白了就是一个快捷方式。
    # Usage:
    #   extend Ktv::Helpers::Config
    #   include Ktv::Helpers::Config
    module Config
      def config
        Ktv.config
      end
      def logger
        Ktv.config.logger
      end
    end
    
  end
end
