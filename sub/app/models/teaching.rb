class Teaching
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :course
  embeds_many :teaching_klasses
  field :teacher
  field :credit
  field :judge
  def self.shoudongtianjia!(item,*teachers)
    teachers.each do |tea|
      item.teachings.find_or_create_by(teacher:tea)
    end
    admin = Ktv::DiscuzAdmin.new
    admin.start_mode :cnu
    admin.orthodoxize_course item
  end
end
