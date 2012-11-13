require "minitest_helper"

FactoryGirl.define do
  factory :user do
    # sequence(:name) { |n| "foo#{n}" }
    name 'foo'
    password 'secret'
    password_confirmation { |u| u.password }
    sequence(:email) { |n| "foo#{n}@example.com" }
  end
  
  factory :courseware do
    title 'foo'
    # sequence(:title) { |n| "cw#{n}" }
  end
end