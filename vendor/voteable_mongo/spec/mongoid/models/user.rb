# -*- encoding : utf-8 -*-
class User
  include Mongoid::Document
  include Mongo::Voter
end
