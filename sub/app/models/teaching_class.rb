class TeachingKlass
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :teaching
  field :number
  field :weekspan # 周次
  field :weekday # 星期
  field :klassnum # 节次
  field :geo_location # 校区
  field :geo_building # 教学楼
  field :geo_classroom # 教室
  field :capacity # 课容量
  field :stu_size # 学生数
end
