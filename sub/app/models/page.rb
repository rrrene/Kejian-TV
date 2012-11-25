# -*- encoding : utf-8 -*-
class Page < ActiveRecord::Base
  include ActiveBaseModel
  def courseware
    @courseware = nil if self.courseware_id_changed?
    @courseware ||= Courseware.find(self.courseware_id)
  end
  def course
    @course = nil if self.courseware_id_changed?
    @course ||= Course.where(fid:self.courseware.course_fid).first
  end
  # todo: teacher
  def courseware_title
    self.courseware.try(:title).to_s
  end
  def courseware_course_fid
    self.courseware.try(:course_fid).to_i
  end
  def courseware_sort1
    self.courseware.try(:sort1).to_s
  end
  def courseware_sort
    self.courseware.try(:sort).to_s
  end
  def courseware_subsite
    self.courseware.subsite
  end
  def course_name
    self.course.try(:name).to_s
  end
  def course_fid
    self.course.try(:fid).to_i
  end
  include Tire::Model::Search
  def self.reconstruct_indexes!
    tire_index_ret = Tire.index(elastic_search_psvr_index_name) do
      delete
      create(:settings=>{
        'analysis'=>{
          'analyzer'=>{
            'psvr_analyzer'=>{
              type: 'custom',
              tokenizer: 'smartcn_sentence',
              filter: [ 'smartcn_word' ],
            },
          }
        }
      },
      :mappings=>{
        "page"=>{"properties"=>{
          'body'=>{"type"=>"string",'analyzer'=>'psvr_analyzer'},
          "courseware_title"=>{"type"=>"string",'boost'=>10,'analyzer'=>'psvr_analyzer'},

          "course_fid"=>{"type"=>"long",'index'=>'not_analyzed'},
          "courseware_id"=>{"type"=>"string",'index'=>'not_analyzed'},
          "courseware_ktvid"=>{"type"=>"string",'index'=>'not_analyzed'},
          "courseware_sort"=>{"type"=>"string",'index'=>'not_analyzed'},
          "courseware_sort1"=>{"type"=>"string",'index'=>'not_analyzed'},
          "page_index"=>{"type"=>"long"}
        }}
      })
      refresh
      binding.pry
      return tire_index_ret
    end
  end
  include_root_in_json = false
  def to_indexed_json
    to_json(methods: [:courseware_title,:courseware_sort1,:courseware_sort,:courseware_subsite,:course_name,:course_fid])
  end
  def self.psvr_search(page,per_page,params)
    from=per_page*(page-1)
    size=per_page
    h={
      "query"=> {
        "bool"=> {
          "must"=> [],
          "must_not"=> [],
          "should"=> [
            {
              "query_string"=> {
                "default_field"=> "courseware_title",
                "query"=> params[:q],
                "analyzer" => "psvr_analyzer",
                "default_operator"=> "AND",
                "boost"=>10,
              }
            },
            {
              "query_string"=> {
                "default_field"=> "body",
                "query"=> params[:q],
                "analyzer" => "psvr_analyzer",
                "default_operator"=> "AND",
              }
            }
          ]
        }
      },
      "from"=> from,
      "size"=> size,
      "sort"=> ["_score"],
      "highlight" => {
        "pre_tags" => [""],
        "post_tags" => [""],
        "fields" => {
          "courseware_title" => {"number_of_fragments" => 0},       
          "body" => {"fragment_size" => 50, "number_of_fragments" => 3}
        }
      },
      "facets"=> {}
    }
    url = "http://localhost:9200/#{elastic_search_psvr_index_name}/page/_search?from=#{from}&size=#{size}"
    response = Tire::Configuration.client.get(url, h.to_json)
    if response.failure?
      STDERR.puts "[REQUEST FAILED] #{h.to_json}\n"
      raise Ktv::Shared::SearchRequestFailed, response.to_s
    end
    json     = MultiJson.decode(response.body)
    return Tire::Results::Collection.new(json, :from=>from,:size=>size)
  end
end

