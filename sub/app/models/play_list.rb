# -*- encoding : utf-8 -*-
class PlayList
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  # sort by this
  field :score,:type=>Integer,:default=>0  
  field :status
  scope :normal, where(:status => 0 )
  # 0 normal
  # 1 cw.ktvid.blank
  # 2 less than two coursewares
  # 3 inner cw is abnormal or transcoding
  scope :undestroyable, where(:undestroyable=>true)
  scope :destroyable, where(:undestroyable.ne=>true)
  
  field :privacy, :type=>Integer, :default=>0
  scope :no_privacy, where(:privacy => 0)

  field :undestroyable,:type=>Boolean,:default=>false
  
  field :is_history,:type=>Boolean,:default=>false
  scope :not_history, where(:ishistory => false)
  
  field :subsite
  field :uid
  field :author # slug
  field :ktvid
  field :school_name
  field :school_id
  field :user_name
  field :user_id
  field :topic
  field :topics
  field :topic_id
  field :course_fids,:type=>Array,:default=>[]
  field :teacher
  field :teacher_typeid
  field :title
  validates :title,:presence =>true
  field :title_en
  field :coursewares_count
  field :views_count,:type=>Integer,:default=>0
  field :ibeike_course_id
  field :sort1

  field :content,:type=>Array,:default=>[]
  field :content_delete_cache,:default=>nil
  field :annotation,:type=>Array,:default=>[]
  field :page_mark,:type=>Array,:default=>[]
  field :history_time_mark,:type=>Array,:default=>[]
  
  field :playlist_thumbnail_kejian_id
  field :content_total_pages,:type=>Integer,:default=>0
  field :content_memos,:type=>Hash,:default=>{}
  field :content_ktvids,:type=>Array,:default=>[]
  field :desc # 备注
  field :tid
  field :playlist_allow_embedding,:type=>Boolean,:default => true
  field :playlist_allow_ratings,:type=>Boolean,:default => true
  field :vote_up,:type=>Integer,:default=>0
  field :vote_down,:type=>Integer,:default=>0
  field :playlist_enable_grid_view,:type=>Boolean,:default => false
  field :disliked_user_ids, :type => Array, :default => []
  field :liked_user_ids, :type => Array, :default => []

  
  # index :content
  scope :series_by_cw, proc{|cw_id|CoursewareSeries.where(:content=>cw_id)}
  def self.run_later
    PlayList.all.map{|x| x.ua(:title_en,Pinyin.t(x.title))}
    PlayList.all.each do |x| 
        x.content.each do |id|
          cw=Courseware.find(id)
          x.content_total_pages = 0
          x.content_total_pages += cw.slides_count
        end
        x.save(:validate => false)
    end
  end
  
  def disliked_by_user(user)
    self.disliked_user_ids ||=[]
    if user.thanked_play_list_ids.include?(self.id)
      user.thanked_play_list_ids.delete(self.id)
      self.liked_user_ids.delete(user.id)
      self.inc(:vote_up,-1)
      user.save(:validate=>false)
    end
    if self.disliked_user_ids.index(user.id)
      self.disliked_user_ids.delete(user.id)
      self.inc(:vote_down,-1)
      self.save(:validate=>false) 
      return false
    end
    self.disliked_user_ids << user.id
    self.inc(:vote_down,1)
    self.save(:validate=>false)
    return true
  end
  
  def self.locate(user_id,title)
    self.find_or_create_by(user_id:user_id,title:title)
  end
  def self.create_defaults_for_all_users
    User.all.each do |u|
      x=PlayList.find_or_create_by(user_id:u.id,title:'收藏')
      y=PlayList.find_or_create_by(user_id:u.id,title:'稍后阅读')
      z=PlayList.find_or_create_by(user_id:u.id,title:'历史记录')
      x.update_attribute(:undestroyable,true)
      y.update_attribute(:undestroyable,true)
      z.update_attribute(:undestroyable,true)
    end
  end
  def self.on_off_history(user_id,op='off')
    if op == 'off'
      User.find(user_id).ua(:mark_history,false)
    elsif op == 'on'
      User.find(user_id).ua(:mark_history,true)
    end
  end
  def self.clear_history(user_id)
    pl = PlayList.where(:user_id=>user_id,:undestroyable=>true,:title=>'历史记录').first
    pl.content = []
    pl.page_mark = []
    pl.history_time_mark = []
    if pl.save(:validate=>false)
      return true
    else
      return false
    end
  end
  def self.remove_one_history(user_id,cwid,time)
    return false if !Moped::BSON::ObjectId.legal?(cwid)
    pl = PlayList.where(:user_id=>user_id,:undestroyable=>true,:title=>'历史记录').first
    cw = Courseware.find(cwid)
    return false if cw.nil?
    if pl.content.include?(cw.id) and pl.history_time_mark.include?(time)
      index = pl.history_time_mark.index(time)
      pl.content.delete_at(index)
      pl.annotation.delete_at(index)
      pl.page_mark.delete_at(index)
      pl.history_time_mark.delete_at(index)
      pl.save(:validate=>false)
      return true
    end
    return false
  end
  def self.add_to_history(user_id,cwid,page=nil)
    pl = PlayList.where(:user_id=>user_id,:undestroyable=>true,:title=>'历史记录').first
    return false if !User.find(user_id).mark_history
    return false if !Moped::BSON::ObjectId.legal?(cwid)
    cw = Courseware.find(cwid)
    return false if cw.nil?
    if pl.content.include?(cw.id)
      index = pl.content.rindex(cw.id)
      gap = Time.now.to_i - pl.history_time_mark[index]
      if gap < 1.week
        if page.nil?
          page_mark = pl.page_mark[index]
        else
          page_mark = page
        end
        pl.history_time_mark.delete_at(index)
        pl.page_mark.delete_at(index)
        pl.content.delete_at(index)
        # query = {:user_id=>user_id,:undestroyable=>true,:title=>'历史记录'}
        # pull = {content:cw.id,page_mark:pl.page_mark[index],history_time_mark:pl.history_time_mark[index]}
        # pl.collection.find_and_modify(query:query,update:{"$pull"=>pull},new:true)
        # push = {content:cw.id,page_mark:page_mark,history_time_mark:Time.now.to_i}
        # pl.find_and_modify(update:{"$push"=>push},new:true)
        pl.content << cw.id
        pl.annotation << ''
        pl.page_mark << page_mark
        pl.history_time_mark << Time.now.to_i
        pl.save
        return true
      end
    end
    if page.nil?
      page_mark = pl.page_mark[index]
    else
      page_mark = page
    end
    # query = {:user_id=>user_id,:undestroyable=>true,:title=>'历史记录'}
    # push = {content:cw.id,page_mark:page_mark,history_time_mark:Time.now.to_i}
    # pl.find_and_modify(update:{"$push"=>push},new:true)
    pl.content << cw.id
    pl.annotation << ''
    pl.page_mark << page_mark
    pl.history_time_mark << Time.now.to_i
    pl.save
    return true
  end
  
  def self.add_to_read_later(user_id,cwid,title='稍后阅读')
      return false if !Moped::BSON::ObjectId.legal?(cwid)
      cw=Courseware.find(cwid)
      return false if cw.nil?
      pl = PlayList.where(:user_id=>user_id,:undestroyable=>true,:title=>title).first
      return false if pl.content.include?(cw.id)
      pl.content << cw.id
      pl.annotation << ''
      if pl.save(:validate=>false)
        return pl.id
      else
        return false
      end
  end
  def self.remove_from_read_later(user_id,cwid,title='稍后阅读')
      return false if !Moped::BSON::ObjectId.legal?(cwid)
      cw = Courseware.find(cwid)
      return false if cw.nil?
      pl = PlayList.where(:user_id=>user_id,:undestroyable=>true,:title=>title).first
      return false if !pl.content.include?(cw.id)
      pl.annotation.delete_at(pl.content.index(cw.id))
      pl.content.delete(cw.id)
      if pl.save(:validate=>false)
        return pl.id
      else
        return false
      end
  end
  def self.exist_in_read_later?(user_id,cwid)
      return false if !Moped::BSON::ObjectId.legal?(cwid)
      pl = PlayList.where(:user_id=>user_id,:undestroyable=>true,:title=>'稍后阅读').first
      return true if pl.content.include?(Courseware.find(cwid).id)
      return false
  end
  def add_one_thing(thing,ding=false)
    return false if !Moped::BSON::ObjectId.legal?(thing.to_s)
    cw = Courseware.find(thing)
    return false if cw.nil?
    return false if self.content.include?(cw.id)
    if ding
      self.content.unshift(cw.id)
      self.annotation.unshift('')
    else
      self.content<<cw.id
      self.annotation << ''
    end
    self.save(:validate=>false)
  end
  
  def thread_inst
    PreForumThread.find_by_tid(self.tid)
  end

  before_save :thumb_ktvids_op
  def set_status
    #todo
  end
  def thumb_ktvids_op
    if self.undestroyable == true
        if self.title_changed? or self.desc_changed? or self.privacy_changed? or self.is_history_changed? or self.user_id_changed?
            return false
        end
    end
    self.title_en = Pinyin.t self.title
    self.status=0
    self.coursewares_count = self.content.nil? ? 0 : self.content.size
    harr=[]
    arr=[]
    content = []
    if !self.content.nil?
      self.content.each_with_index do |id,index|
        cw=Courseware.where(id:id).first
        if cw.nil?
          next
        end
        self.status=3 if cw.status != 0
        self.status=1 if cw.ktvid.blank?
        ### Liber TODO raise exception and log 
        self.content_total_pages += cw.slides_count if self.content_changed?
        harr << cw.ktvid
        arr << cw.course_fid
        content[index] = cw.id
      end
    end
    self.content = content.compact
    self.annotation = self.annotation.to_a
    self.status=2 if self.content.nil? or self.content.count < 2
    self.content_ktvids=harr
    self.course_fids=arr.uniq.compact
    if self.undestroyable == true
      self.status = 0
    end
  end
  unless $psvr_really_development
    include Tire::Model::Search
    include Tire::Model::Callbacks
  end
  def self.reconstruct_indexes!
    Tire.index('play_lists') do
      delete
      create(:settings=>{
        'analysis'=>{
          'analyzer'=>{
            'psvr_analyzer'=>{
              type: 'custom',
              tokenizer: 'smartcn_sentence',
              filter: [ 'smartcn_word' ],
            },
          }
        }
      },
      :mappings=>{
        "play_list"=>{"properties"=>{
          'title'=>{"type"=>"string",'analyzer'=>'psvr_analyzer','boost'=>100},
          'desc'=>{"type"=>"string",'analyzer'=>'psvr_analyzer','boost'=>10},
          "courseware_titles"=>{
            "properties" => {
              "title" => {"type"=>"string",'analyzer'=>'psvr_analyzer'},
              "id" => {"type"=>"string",'index'=>'not_analyzed'},
            }
          },
        }}
      })
      refresh
    end
  end
  include_root_in_json = false
  def to_indexed_json
    {
      title:self.title,
      desc:self.desc,
      courseware_titles:self.content.collect{|id|
        ret={}
        ret['id']=id
        ret['title']=Courseware.get_title(id)
        ret
      },
    }.to_json
  end
  def self.psvr_search(page,per_page,params)
    from=per_page*(page-1)
    size=per_page
    h={
      "query"=> {
        "bool"=> {
          "must"=> [],
          "must_not"=> [],
          "should"=> [
            {
              "query_string"=> {
                "default_field"=> "title",
                "query"=> params[:q],
                "analyzer" => "psvr_analyzer",
                "default_operator"=> "AND",
                "boost"=>100,
              }
            },
            {
              "query_string"=> {
                "default_field"=> "desc",
                "query"=> params[:q],
                "analyzer" => "psvr_analyzer",
                "default_operator"=> "AND",
                "boost"=>10,
              }
            },
            {
              "query_string"=> {
                "default_field"=> "courseware_titles.title",
                "query"=> params[:q],
                "analyzer" => "psvr_analyzer",
                "default_operator"=> "AND",
              }
            },
          ]
        }
      },
      "from"=> from,
      "size"=> size,
      "sort"=> ["_score"],
      "highlight" => {
        "pre_tags" => [""],
        "post_tags" => [""],
        "fields" => {
          "title" => {"number_of_fragments" => 0},       
          "desc" => {"fragment_size" => 50, "number_of_fragments" => 3},
          "courseware_titles.title" => {"number_of_fragments" => 0},       
        }
      },
      "facets"=> {}
    }
    url = "http://localhost:9200/play_lists/play_list/_search?from=#{from}&size=#{size}"
    response = Tire::Configuration.client.get(url, h.to_json)
    if response.failure?
      STDERR.puts "[REQUEST FAILED] #{h.to_json}\n"
      raise SearchRequestFailed, response.to_s
    end
    json     = MultiJson.decode(response.body)
    return Tire::Results::Collection.new(json, :from=>from,:size=>size)
  end
  def asynchronously_clean_me
    bad_ids = [self.id]
    Util.bad_id_out_of!(User,:thanked_play_list_ids,bad_ids)
    thanked = false
  end
  def coursewares(alt=nil)
    alt||=self.content
    return Courseware.eager_load(self.content)
  end
  def courseware_titles
    self.coursewares.collect &:title
  end
  def courseware_titles_changed?
    self.content_changed?
  end
  def courseware_titles_was
    self.coursewares(self.content_was).collect &:title
  end
  redis_search_index(:title_field => :title,
                     :alias_field => :courseware_titles,
                     :score_field => :score,
                     :ext_fields => [:coursewares_count,:courseware_titles],
                     :prefix_index_enable => false,
                    )
  alias_method :redis_search_index_create_before_psvr,:redis_search_index_create
  alias_method :redis_search_index_need_reindex_before_psvr,:redis_search_index_need_reindex
  def redis_search_psvr_okay?
    !self.undestroyable and 0==self.status and 0==self.privacy
  end
  def redis_search_index_need_reindex
    if self.status_changed? && self.redis_search_psvr_okay?
      return true
    else
      return self.redis_search_index_need_reindex_before_psvr
    end
  end
  def redis_search_index_create
    if self.redis_search_psvr_okay?
      return self.redis_search_index_create_before_psvr
    else
      return true
    end
  end
end

