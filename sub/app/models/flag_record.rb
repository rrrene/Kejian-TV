# -*- encoding : utf-8 -*-
class FlagRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  
  field :cwid
  field :flag_user_ids,:type=>Array,:default=>[]
  field :flag_page,:type=>Integer
  field :flag_protected_group
  field :flag_desc
   
  field :user_id
  field :layer
  field :reason_id
  field :atype,:type=>Integer,:default=>0
  field :deletor_id
  
  field :times,:type=>Integer,:default=>1
  COURSEWARE = 0
  COMMENT = 1
  
  TYPE_FLAGED = {FlagRecord::COURSEWARE => '课件',FlagRecord::COMMENT => '评论'}
  
  # FLAG_DETAILS = { reason_id => reason_name}
  FLAG_DETAILS = {
      "P"=>"色情内容",
      "1"=>"图解性行为",
      "2"=>"裸露",
      "3"=>"有挑逗内容，但无裸露",
      "4"=>"其他色情内容",
      "G"=>"暴力或令人反感的内容",
      "5"=>"成人格斗",
      "6"=>"身体攻击",
      "7"=>"青少年暴力",
      "8"=>"虐待动物",
      "9"=>"宣传恐怖主义",
      "R"=>"憎恨或辱骂内容",
      "10"=>"宣传仇恨或暴力",
      "23"=>"恃强凌弱",
      "11"=>"恐吓",
      "X"=>"有害的危险动作",
      "12"=>"药物滥用或吸毒",
      "13"=>"滥用火或炸药",
      "24"=>"自杀或自残",
      "14"=>"其他危险动作",
      "J"=>"虐待儿童",
      "Z"=>"垃圾内容",
      "18"=>"大量广告",
      "19"=>"误导性文字",
      "20"=>"误导性缩略图",
      "21"=>"欺骗/欺诈"
  }
  
  FLAG_PROTECTED_GROUP ={
        "age"=>"年龄",
        "color"=>"颜色",
        "disability"=>"行为障碍",
        "ethnic origin"=>"民族",
        "gender identity"=>"性别认定",
        "national origin"=>"国籍",
        "race"=>"赛跑",
        "religion"=>"宗教",
        "sex"=>"色情",
        "sexual orientation"=>"性取向",
        "veteran status"=>"最佳状态"
  }
  
end
