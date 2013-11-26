# -*- encoding : utf-8 -*-
class NaughtyWord
  include Mongoid::Document
  field :word
  validates_uniqueness_of :word
  field :deleted,:type=>Integer,:default=>0
  field :created_at,:type=>Time
  field :user_id
  field :level,:type=>Integer,:default=>1
  WORD_LEVEL={1=>"一级",2=>"二级"}
  
  def add_words(user_id)
    File.open(File.join(Rails.root,'public/uploads/words.txt')) do |f|
      while line=f.gets
        begin
          if line.strip != "" and NaughtyWord.where(:word=>line.strip,:deleted.ne=>1).first.blank?
            word=NaughtyWord.find_or_initialize_by(:word=>line.strip)
            word.word=line.strip
            word.created_at=Time.now.getlocal
            word.level=1
            word.user_id=user_id
            word.deleted=0
            word.save
          end
        rescue Exception => e
          puts e
        end
      end
    end
  end
end
