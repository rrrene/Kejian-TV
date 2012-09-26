require "rubygems"
require "bundler/setup"

require 'ostruct'
require 'active_support/core_ext'
require 'sidekiq'
require 'grim'
require 'pry'
require File.expand_path("../../../app/jobs/transcoder_job.rb",__FILE__)

describe TranscoderJob do
  it "can download, analyze and transcode PDF&DJVU that is stored remotely" do
    ['thin_pdf.pdf','DjVu in 1999.djvu'].each do |test_filename|
      # input
      cw=OpenStruct.new
      cw.id='testid'
      cw.remote_filepath="http://testuser:testpass@_toys.kejian.lvh.me/#{test_filename}"
      cw.pdf_filename=test_filename
      cw.really_remote=true 
      cw.sort=File.extname(test_filename).split('.')[-1].to_sym
      # run ----------------------------------------------------
      snda = OpenStruct.new
      snda.stub(:save=>true)
      $snda_ktv_eb = Object.new
      $snda_ktv_eb.stub_chain(:objects,:build=>snda)
      $snda_ktv_down = Object.new
      $snda_ktv_down.stub_chain(:objects,:build=>snda)
      cw.md5hash={}
      cw.slides_counts={}
      cw.version=0
      cw.stub(:save=>true)
      cw.stub(:check_upyun_result=>true)
      cw.stub(:update_attribute) do |k,v|
        cw.send("#{k}=",v)
      end
      fake_Courseware=Object.new
      fake_Courseware.stub(:find).with('testid').and_return(cw)
      fake_Courseware.stub_chain(:where,:first=>nil)
      stub_const('Courseware',fake_Courseware)
      fake_rails=Object.new
      fake_rails.stub(:root=>File.expand_path("../../_fake_rails_root/",__FILE__))
      stub_const('Rails',fake_rails)
      job = TranscoderJob.new
      job.perform('testid')
      # output -------------------------------------------------
      cw.width.should be_present
      cw.height.should be_present
      cw.slides_count.should be > 0
      cw.md5.should be_present
      cw.version.should be 0
      cw.slides_counts['0'].should eq cw.slides_count
      cw.md5hash['0'].should eq cw.md5
      cw.md5s.should eq [cw.md5]
      cw.pdf_slide_processed.should be > 0
    end
  end
end
