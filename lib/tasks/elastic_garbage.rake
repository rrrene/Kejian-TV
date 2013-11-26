namespace :ktv do
  task :elastic_garbage do
    size=100
    i = 0
    while true
      i += 1
      from=100*(i-1)
      h = {from:from,size:size}
      response = Tire::Configuration.client.get('http://localhost:9200/coursewares/_search?pretty=true&q=*:*', h.to_json);
      json     = MultiJson.decode(response.body);
      ret = Tire::Results::Collection.new(json, :from=>from,:size=>size);
      break if ret.size==0
      ret.each do |item|
        cw = Courseware.where(id:item['id']).first
        if cw.nil?
          p item
          
        end
      end
    end
  end
end
