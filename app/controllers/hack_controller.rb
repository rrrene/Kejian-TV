# -*- encoding : utf-8 -*-
class HackController < ApplicationController
  def htc
    htc_path = File.join(Rails.root,'lib', 'PIE.htc')
    send_file htc_path, :type => 'text/x-component',:disposition=>'inline',:url_based_filename=>true
  end
end
