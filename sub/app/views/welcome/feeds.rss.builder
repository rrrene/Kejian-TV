xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{Setting.ktv_subname}课件交流系统"
    xml.description "最新课件"
    xml.link '/welcome/index'

    for cw in @coursewares
      xml.item do
        xml.title cw.title
        xml.description cw.body
        xml.pubDate cw.created_at.to_s(:rfc822)
        xml.link "/coursewares/#{cw.id}"
        xml.guid "/coursewares/#{cw.id}"
      end
    end
  end
end

