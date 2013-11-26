# -*- encoding : utf-8 -*-
module CdnHelper
  def asset_url(path)
    url = "http://ktv-pic.b0.upaiyun.com/#{path}"
    # Net::HTTP.start("ktv-pic.b0.upaiyun.com", 80) do |http|
    #   if http.head(url).code == "200"
    #     return url
    #   else
    #     return asset_path('yt/img/mqdefault.jpg')
    #   end
    # end
  end
  def asset_url_eb(path)
    "http://storage-huabei-1.sdcloud.cn/ktv-eb/#{path}"
  end
  module_function(*instance_methods)
end
