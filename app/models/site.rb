# -*- encoding : utf-8 -*-
class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :name_short
  def self.name_short_temp
    self.all.each{|x| puts "Site.where(name:'#{x.name}').first.update_attribute(:name_short,'')"}
  end
  def self.generate_footer
    self.asc('created_at').each do |site|
      puts %Q{<span style="color:rgb(#{site.background_color});font-size:140%">■</span>&nbsp;<a href="http://#{site.slug}.kejian.tv" target="_blank">#{site.name_eng}.kejian.tv #{site.name}</a>&nbsp;}
    end
  end
  field :slug
  field :belong_where
  validates_uniqueness_of :name,:slug
  validates_presence_of :belong_where,:name,:slug
  field :subsite_url    #for our *.kejian.tv
  field :alias_url    #for  kejian.ibeike.com
  field :background_color
  field :fore_color
  field :att,:type => Hash,:default => {}
  field :err_msgs,:type=>Array,:default=>[]
  field :desc
  field :logo_url
  field :icon_url
  field :external_url1_name
  field :external_url1
  field :external_url2_name
  field :external_url2
  field :coursewares_count,:type => Integer,:default=>0
  field :creation_date,:type => Date
  field :comments_count ,:type => Integer,:default=>0
  field :download_count,:type => Integer,:default=>0
  field :user_count,:type => Integer,:default=>0
  field :upload_per_day,:type => Integer,:default=>0
  field :biji_count,:type => Integer,:default=>0
  
  field :top_user_names
  field :top_user_credits
  field :top_user_profile_urls
  field :top_urer_figure_urls
  field :hot_course_ware_name
  field :hot_course_ware_url
  field :hot_course_ware_updated_at,:type => Date
  field :hidden,:type=>Boolean,:default=>true
  field :uc_key
  field :uc_appid
  field :uc_simpleappid
  def import_ids(uc=nil)
    if(!uc)
      uc=Ktv::Uc.new
      uc.login!
    end
    uc_simpleappid,uc_appid,uc_key=uc.get_ids(self.slug)
    self.update_attribute(:uc_key,uc_key)
    self.update_attribute(:uc_appid,uc_appid)
    self.update_attribute(:uc_simpleappid,uc_simpleappid)
  end
  def self.generate_site(todo)
  end
  def name_eng
    self.slug=='ibeike' ? 'iBeiKe' : self.slug.upcase
  end
  def generate_yml1
    puts "sub_#{self.slug}: &sub_#{self.slug}"
    puts "  uc_simpleappid: '#{self.uc_simpleappid}'"
    puts "  uc_appid: '#{self.uc_appid}'"
    puts "  uc_key: '#{self.uc_key}'"
    puts "  ktv_sub: '#{self.slug}'"
    puts "  ktv_subname: '#{self.name}'"
    puts "  ktv_subname_short: '#{self.name_short}'"
    puts "  ktv_subname_eng: '#{self.name_eng}'"
    puts "  ktv_subdomain: '#{self.slug}.kejian.tv'"
    
    self.class.puts_logo_info(self.slug)
    puts ''
  end
  def self.puts_logo_info(slug)
    logo_info = `identify "#{File.expand_path('../sub/app/assets/images/logo_ktv_'+slug+'.png',Rails.root)}"`
    if logo_info=~/PNG (\d+)x(\d+)/
      puts "  logo_ktv_width: #{$1}"
    else
      raise 'no logo'
    end
  end
  def generate_yml_database
    puts <<BBB
sub_#{self.slug}: &sub_#{self.slug}
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: ktv_sub_#{self.slug}
  pool: 5
  username: root
  password: "jknlff8-pro-17m7755"
  socket: /tmp/mysql.sock
BBB
  end
  def generate_yml_mongo
    puts <<BBB
sub_#{self.slug}: &sub_#{self.slug}
  host: '0.0.0.0'
  database: ktv_sub_#{self.slug}
BBB
  end
  def generate_yml_redis(port)
    puts <<BBB
sub_#{self.slug}: &sub_#{self.slug}
  <<: *defaults
  port: #{port}
BBB
  end
  def generate_hosts
    puts "127.0.0.1 #{self.slug}.kejian.tv"
  end

  
  DOMAIN_DISTRICT={
    'north' => '华北院校',
    'east' => '华东院校',
    'northeast' => '东北院校',
    'middle' => '华中院校',
    'south' => '华南院校',
    'southwest' => '西南院校',
    'northwest' => '西北院校',
    'hkmctw' => '港澳台院校',
    'outboard' => '海外院校',
    'professional' => '学科站点',
    'topic_induced' => '特殊主题'
  }
  def ask_for_load_top_user
    
  end
  
  def ask_for_load_hot_course_ware
    
  end

  def sizeklass
    case self.slug
    when 'ibeike'
      'gv-size-big'
    when 'cnu','buaa','ruc'
      'gv-size-medium'
    else
      'gv-size-small'
    end
=begin
todo

    if self.coursewares_count>2000
      'gv-size-big'
    elsif self.coursewares_count<=2000 and self.coursewares_count>100
      'gv-size-medium'
    else
      'gv-size-small'
    end
=end
  end
end
