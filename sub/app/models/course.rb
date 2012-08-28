class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  field :department
  field :number
  field :name
  field :fid
  field :coursewares_count,:type=>Integer,:default=>0
  field :years,:type=>Array,:default=>[]
  embeds_many :teachings
  def self.reflect_onto_discuz!
    self.asc('number').each_with_index do |item,index|
      PreForumForum.insert2(1,"[#{item.number}] #{item.name}",index+1)
    end
    self.fid_fill!
  end
  def self.fid_fill!
    self.asc('number').each_with_index do |item,index|
      item.update_attribute(:fid,PreForumForum.find_by_name("[#{item.number}] #{item.name}").fid)
    end
  end
  def self.shoudongtianjia!(department,number,name)
    item=self.create!(department:department,number:number,name:name)
    f=PreForumForum.insert2(1,"[#{item.number}] #{item.name}",PreForumForum.count+1)
    item.update_attribute(:fid,f.fid)
  end
end

