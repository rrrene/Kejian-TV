# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140408102925) do

  create_table "coursewares", force: true do |t|
    t.string   "md5"
    t.string   "title"
    t.string   "state"
    t.string   "klass"
    t.string   "school_name"
    t.string   "department_name"
    t.string   "user_name"
    t.string   "course_name"
    t.integer  "school_id"
    t.integer  "department_id"
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "width"
    t.integer  "height"
    t.integer  "original_width"
    t.integer  "original_height"
    t.integer  "slides_count"
    t.integer  "words_count"
    t.integer  "views_count"
    t.integer  "human_time"
    t.string   "file_name"
    t.integer  "file_size"
    t.string   "file_size_note"
    t.integer  "file_slides_processed"
    t.string   "file_sort"
    t.string   "file_sort_mundane"
    t.string   "file_remote_path"
    t.text     "file_info"
    t.text     "file_info_raw"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lang"
  end

end
