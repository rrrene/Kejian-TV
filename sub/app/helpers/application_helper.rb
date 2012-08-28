# -*- encoding : utf-8 -*-
module ApplicationHelper
  def kaixue_msg
    day=(Time.now-$cnu_new)/86400
    day=day.to_i
    if day < 0
      return "今天离开学还有#{-day}天"
    else
      return "今天是开学第#{day}天"
    end
  end
  def cpath(c)
    "/simple/forum.php?mod=forumdisplay&fid=#{c.fid}"
  end
end
