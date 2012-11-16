# -*- encoding : utf-8 -*-
class ApiSubdomain
  def self.matches?(request)
    request.subdomain.present? and request.subdomain.starts_with?('api')
  end
end

class ApiSubdomainNOT
  def self.matches?(request)
    !ApiSubdomain.matches?(request)
  end
end
