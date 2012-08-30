# -*- encoding : utf-8 -*-
module CdnHelper
  def asset_url(path)
    "http://ktv-pic.b0.upaiyun.com/#{path}"
  end
  def asset_url_eb(path)
    "http://storage-huabei-1.sdcloud.cn/ktv-eb/#{path}"
  end
end
