class Courseware
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  field :title
  field :tid
  field :pdf_filename
  field :filesize
  field :sort
  field :downloads_count, :type => Integer, :default => 0
  def self.import_all!
    PreForumThread.all.each do |thread|
      ins=self.find_or_create_by(tid:thread.tid)
      attachment = PreForumAttachment.where(tid:thread.tid).first
      if attachment
        a = "PreForumAttachment#{thread.tid.to_s[-1]}".constantize.find_by_aid(attachment.aid)
        ins.title = thread.subject
        ins.filesize = a.filesize / 1000
        ins.pdf_filename = a.filename
        ins.sort = File.extname(a.filename)
        ins.sort = ins.sort[1..-1] if '.'==ins.sort[0]
        ins.downloads_count = attachment.downloads
        ins.save(:validate=>false)
      end
    end
  end
end
