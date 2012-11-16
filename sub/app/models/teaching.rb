# -*- encoding : utf-8 -*-
class Teaching
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :course
  embeds_many :teaching_klasses
  field :teacher
  field :credit
  field :judge
  field :typeid
  
  def import_typeid
    self.update_attribute(:typeid,PreForumThreadclass.find_by_name(self.teacher).typeid)
  end
  def self.add_ibeikeTeachers_and_user_add_Courses!
    teacher_ibeike = OcwCourses.select("yuanxi,title,teacher,Comp").map{|v| [v.title,[v.yuanxi,v.teacher,v.Comp]]}
    teacher_ibeike.each do |hash|

        department = Department.where(name:hash[1][0]).first
        binding.pry if department.nil?
        course = Course.where(name:hash[0])
        course = Course.where(name:hash[0],department:department.name) if course.count>1
        course = course.first
        if course.nil?
         course=Course.create!(name:hash[0],department:department.name,ctype:hash[1][2])
        end
        binding.pry if course.nil?
        course.teachings.find_or_create_by(teacher:hash[1][1]).save(:validate=>false)
        
        course.save(:validate=>false)
        puts (course.number.nil? ? "nil" : course.number) + ':' + course.name + ':' + course.ctype + ':' + course.department 
    end
    #Course.all.each{|x| x.update_attribute(:years,[20122])}
    #OcwCourses.import_into_Courses
    #Department.reflect_onto_discuz!
    #Course.reflect_onto_discuz!
    #add_ibeikeTeachers_Doit teacher_ibeike
  end
  
  def self.add_ibeikeTeachers_Doit(teacher_ibeike = nil)
    teacher_ibeike.nil? ? teacher_ibeike = OcwCourses.select("yuanxi,kemu,teacher,Comp").map{|v| [v.kemu,[v.yuanxi,v.teacher,v.Comp]]} : teacher_ibeike
    admin = Ktv::DiscuzAdmin.new
    admin.start_mode Setting.ktv_sub.to_sym
    @old = Array.new
    teacher_ibeike.each do |hash|
      course = Course.find_or_initialize_by(name:hash[0],ctype:hash[1][2],department:hash[1][0])
      if !course.nil?
        if !@old.include?(course.fid)
          @old << course.fid
          admin.orthodoxize_course course 
        end
      else
        puts hash.values[0][0].to_s + "  :nothing"
      end
    end
  end
  
  def self.shoudongtianjia!(item,*teachers)
    teachers.each do |tea|
      item.teachings.find_or_create_by(teacher:tea)
    end
    admin = Ktv::DiscuzAdmin.new
    admin.start_mode Setting.ktv_sub.to_sym
    admin.orthodoxize_course item
  end
end
