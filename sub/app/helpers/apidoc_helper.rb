module ApidocHelper
  def api(num)
    "<img src=\"/apidoc_static/images/#{num}.png\" />".html_safe
  end
end