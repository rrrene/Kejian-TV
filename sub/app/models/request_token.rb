# -*- encoding : utf-8 -*-
class RequestToken < OauthToken
  attr_accessor :provided_oauth_verifier

  def authorize!(user)
    return false if authorized?
    self.user           = user
    self.authorized_at  = Time.now
    self.verifier       = OAuth::Helper.generate_key(20)[0,20] unless oauth10?
    self.save
  end

  def exchange!
    return false unless authorized?
    return false unless oauth10? || verifier == provided_oauth_verifier

    AccessToken.create(:user => user, :client_application => client_application).tap do
      invalidate!
    end
  end

  def to_query
    if oauth10?
      super
    else
      "#{super}&oauth_callback_confirmed=true"
    end
  end
  
  def oauth10?
    (defined? OAUTH_10_SUPPORT) && OAUTH_10_SUPPORT && self.callback_url.blank?
  end
  
=begin
If
  the client is unable to receive callbacks or a
  callback URI has been established via other means,
  the parameter value MUST be set to "oob" (case
  sensitive), to indicate an out-of-band
  configuration.
=end  
  def oob?
    callback_url.nil? || callback_url.downcase == 'oob'
  end
  
end
