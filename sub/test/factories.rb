require "minitest_helper"

FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "foo#{n}" }
    password 'secret'
    password_confirmation { |u| u.password }
    sequence(:email) { |n| "foo#{n}@example.com" }
  end
end