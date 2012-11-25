# -*- encoding : utf-8 -*-
require "test_helper"

describe Page do
  it "二级索引" do
    Page.reconstruct_indexes!
    @cw=Courseware.non_redirect.nondeleted.normal.is_father.first
    body = "FUCKFUCKFUUUUUUUUUUUCKpgpg#{Page.count+1}"
    p=Page.create!(courseware_id:@cw.id.to_s,body:body)
    p.tire.update_index
    Page.tire.index.refresh;assert Page.psvr_search(1,1,{q:body}).first.try(:id).to_s == p.id.to_s, '可以建立二阶索引'
    Tire.index(p.class.elastic_search_psvr_index_name) do
      remove p
    end
    Page.tire.index.refresh;refute Page.psvr_search(1,1,{q:body}).first.try(:id).to_s == p.id.to_s, '可以删除二阶索引'
  end
end

