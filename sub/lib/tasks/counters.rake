namespace :ktv do
  task :counters => :environment do 
    User.all.each{|x| print x.coursewares_count.to_s;x.ua(:coursewares_count,Courseware.non_redirect.nondeleted.normal.is_father.where(:uploader_id=>x.id).count);print "--#{x.coursewares_count}\n"}
    Course.all.each{|x| x.ua(:coursewares_count,Courseware.non_redirect.nondeleted.normal.is_father.where(:course_fid=>x.fid).count)}
    Department.all.each{|x| x.ua(:coursewares_count,Course.where(:department_fid=>x.fid).inject(0){|memo,obj|memo+obj.coursewares_count})}

  end
end
