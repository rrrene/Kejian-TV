# -*- encoding : utf-8 -*-
class PageTerm < ActiveRecord::Base
  include Redis::Search
  def self.import_from_es!
    # warning: this is an expensive operation!
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{self.table_name}")

    h={
      "query" => {
          "match_all" => {}
      },
      "facets" => {
          "body" => {
              "terms" => {
                  "field" => "body",
                  "all_terms" => true,
              }
          }
      }
    }
    response = Tire::Configuration.client.get("http://localhost:9200/pages/_search?search_type=scan&scroll=1m&size=50", h.to_json)
    raise 'ES GET Failed!' if response.failure?
    json     = MultiJson.decode(response.body)

    h['facets']['body']['terms']['size']=json['facets']['body']['total']
    response = Tire::Configuration.client.get("http://localhost:9200/pages/_search?search_type=scan&scroll=1m&size=50", h.to_json)
    raise 'ES GET Failed!' if response.failure?
    json     = MultiJson.decode(response.body)

    terms = json['facets']['body']['terms']
    sleep 2
    puts "#{terms.count} PageTerms Will Be Imported."
    terms.each do |j|
      item = PageTerm.create! do |term|
        term.t = j['term']
        term.c = j['count']
      end
      p [item.t,item.c]
    end
    puts "#{PageTerm.count} PageTerms Will Be Imported."
  end

  # redis_search_index(:title_field => :t, :score_field => :c, :prefix_index_enable=>true)
end

