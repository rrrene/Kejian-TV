# -*- encoding : utf-8 -*-
module Ktv
  class TreeGenerator
   def self.jsonize(data)
     json = {}
     json[:item] = []
     for v in data[:item]
       # binding.pry
       if v.kind_of?(Array)
         v.each do |k|
           if !k[:item].nil?
             # json[:item]<<{id:"#{rand_one_dirname(1)}",item:v,im0:"book.gif"}  
             puts k
             jsonize(k)
           end
         end
       else
         puts v
           json[:item]<<{id:"#{rand_one_dirname(1)}",text:v,im0:"book.gif"}
       end
       # if !v.blank?
       #   json[:item]<<{id:"#{rand_one_dirname(5)}",text:v,im0:"book.gif"}
       # end
     end
 
     return json
   end
   def self.directory_json(full_path, name=nil)
     filter = ['.DS_Store','.git','.svn']
     data = Hash.new
 
     Dir.glob(full_path+'/**/*') do |filename|
       entry = File.basename(filename)
       path = File.dirname(filename)
       if data["#{path}"].nil?
         data["#{path}"] = []
       end
     
       if !filter.include?(entry)
         if File.directory?(filename)
           data["#{path}"] << [entry,0]
           # puts entry + " : dir"
         else
           data["#{path}"] << [entry,1]
           # puts "---"+ entry + " : file"
         end
       end
     end
     data_bak = data
     puts data
     echo_tree(data)
     test = Hash.new
     test[:id] = 0
     test[:text] = @@aas[0][2]
     test[:item] = []
     return data
   end
   @@aas = []
   def self.echo_tree(data,start = '')
     @@count+=1
     if start != ''
       data[start].sort {|x,y| x[1] <=> y[1]}.each do |i,j|
         if j == 0
           print("..." * @@count)
           puts i + ":" + @@count.to_s + ":  root:#{File.basename(start)}"
           puts "{}"
           @@aas << [File.basename(start),["id","#{rand_one_dirname(6)}"],["text",i,"file"],["im0","#{rand_one_dirname(6)}"],@@count]
           data[start].delete([i,j])
           echo_tree(data,"#{start}/#{i}")
         elsif j==1
           print("..." * @@count)
           puts i+ ":" + @@count.to_s + ":  root:#{File.basename(start)}"
           @@aas << [File.basename(start),["id","#{rand_one_dirname(6)}"],["text",i,"file"],["im0","#{rand_one_dirname(6)}"],@@count]
           data[start].delete([i,j])
         end
       end
     else
       data.each do |key,value|
         value.sort {|x,y| x[1] <=> y[1]}.each do |i,j|
           if j == 0
             print("..." * @@count)
             puts  i+ ":" + @@count.to_s +  ":  root:#{File.basename(key)}"
             @@aas << [File.basename(key),["id","#{rand_one_dirname(6)}"],["text",i,"dir"],["im0","#{rand_one_dirname(6)}"],@@count]
             # binding.pry
             value.delete([i,j])
             echo_tree(data,"#{key}/#{i}")
           elsif j==1
             print("..." * @@count)
             puts i+ ":" + @@count.to_s  + ":  root:#{File.basename(key)}"
              @@aas << [File.basename(key),["id","#{rand_one_dirname(6)}"],["text",i,"file"],["im0","#{rand_one_dirname(6)}"],@@count]
             value.delete([i,j])
           end
         end
       end      
     end
     @@count -= 1
   end
 end
end
