class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :null => false, :default => ""
  field :encrypted_password, :type => String, :null => false, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  def self.authenticate_through_dz_auth!(request,dz_auth,dz_saltkey)
    auth = UCenter::Php.daddslashes(UCenter::Php.authcode(dz_auth,'DECODE',Digest::MD5.hexdigest(Setting.dz_authkey_cnu+dz_saltkey)).split("\t"))
    if(auth.blank? || auth.size < 2)
      return nil
    else
      discuz_pw = auth[0]
      discuz_uid = auth[1]
      info0 = UCenter::User.get_user(request,{username:discuz_uid,isuid:1})
      return nil if '0'==info0
      info = info0['root']['item']
      incoming_opts = {'email' => info[2], 'username' => info[1], 'uid' => info[0], 'password' => discuz_pw}
      u  = nil
      u||= User.where(:email=>incoming_opts['email']).first
      u||= User.where(:slug=>incoming_opts['username']).first
      u||= User.where(:uid=>incoming_opts['uid']).first
      u||= User.new
      u.uid = incoming_opts['uid']
      u.email = incoming_opts['email']
      u.slug = incoming_opts['username']
      u.discuz_pw = incoming_opts['password']
      u.password = incoming_opts['password']
      u.password_confirmation = incoming_opts['password']
      u.save(:validate=>false)
      return u
    end
  end
end
