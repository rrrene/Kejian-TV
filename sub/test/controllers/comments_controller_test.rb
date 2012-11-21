# -*- encoding : utf-8 -*-
require "test_helper"
describe CommentsController do
  before do
    @comment = Comment.nondeleted.first
  end
end