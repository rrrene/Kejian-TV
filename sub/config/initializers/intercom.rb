IntercomRails.config do |config|
  # == Intercom app_id
  # 
  config.app_id = "bbiz3u3s"

  # == Intercom secret key 
  # This is reuqired to enable secure mode, you can find it on your Intercom 
  # "security" configuration page.
  # 
  # config.api_secret = "..."

  # == Intercom API Key
  # This is required for some Intercom rake tasks like importing your users;
  # you can generate one at https://www.intercom.io/apps/api_keys.
  #
  config.api_key = "82d1ccbbccd9305a9fa2f6e8cb0da81757607544"

  # == Curent user name
  # The method/variable that contains the logged in user in your controllers.
  # If it is `current_user` or `@user`, then you can ignore this
  #
  # config.user.current = Proc.new { current_user }
  
  # == User model class
  # The class which defines your user model
  #
  # config.user.model = Proc.new { User }

  # == User Custom Data
  # A hash of additional data you wish to send about your users.
  # You can provide either a method name which will be sent to the current
  # user object, or a Proc which will be passed the current user.
  #
  # config.user.custom_data = {
  #   :plan => Proc.new { |current_user| current_user.plan.name },
  #   :favorite_color => :favorite_color
  # }
 
  config.inbox.style = :custom
  config.inbox.counter = true

end
