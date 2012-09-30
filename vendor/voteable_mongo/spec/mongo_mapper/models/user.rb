# -*- encoding : utf-8 -*-
class User
  include MongoMapper::Document
  include Mongo::Voter
end
