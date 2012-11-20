# -*- encoding : utf-8 -*-
module ApidocHelper
  def api(num)
    "<img src=\"/apidoc_static/images/#{num}.png\" />".html_safe
  end
  module_function(*instance_methods)
end
