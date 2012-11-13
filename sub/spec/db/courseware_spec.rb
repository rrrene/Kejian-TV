# -*- encoding : utf-8 -*-
# require File.expand_path("../_init.rb",__FILE__)
# describe Courseware do
#   it "should enqueue to transcode when user has finished uploading a PDF" do
#     # this the information that we need from the user's browser
#     presentation = Hash.new.with_indifferent_access
#     presentation['id']='testid'
#     presentation['pdf_filename']='testpdf.pdf'
#     # mocking
#     cw=OpenStruct.new
#     cw.id='testid'
#     fake_Courseware.stub(:find).with('testid').and_return(cw)
#     cw_ret=Courseware.presentations_upload_finished(presentation)
#     cw_ret.id.should eq cw 
#   end
# end
# 
