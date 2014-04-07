class WelcomeController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:p1]

  def index
    mode = wl_DetectUserAgent
    if mode == "mobile" || mode == 'basic'
      redirect_to coursewares_path
      return false
    else
      render layout: false
    end
  end

  def introductory_video
    if 1==rand(2)
      redirect_to 'http://www.tudou.com/programs/view/g2Eono37oC0/'
      return false
    else
      redirect_to 'http://v.youku.com/v_show/id_XNjMyNjAxNjY4.html'
      return false
    end
  end

  def i2
    render layout: false
  end

  def i3
    render layout: false
  end

  def i4
    render layout: false
  end

  def i5
    render layout: false
  end

  def i6
    render layout: false
  end

  def i7
    render layout: false
  end

  def i8
    render layout: false
  end

  def i9
    render layout: false
  end

  def p1
    render file:"#{Rails.root}/app/views/welcome/p1.json.erb"
  end
end
