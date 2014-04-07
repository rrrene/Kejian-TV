class CreateCoursewares < ActiveRecord::Migration
  def change
    create_table :coursewares do |t|
      t.string :md5
      t.string :title
      t.string :state
      t.string :klass
      t.string :school_name
      t.string :department_name
      t.string :user_name
      t.string :course_name
      t.integer :school_id
      t.integer :department_id
      t.integer :user_id
      t.integer :course_id
      t.integer :width
      t.integer :height
      t.integer :original_width
      t.integer :original_height
      t.integer :slides_count
      t.integer :words_count
      t.integer :views_count
      t.integer :human_time
      t.string :file_name
      t.integer :file_size
      t.string :file_size_note
      t.integer :file_slides_processed
      t.string :file_sort
      t.string :file_sort_mundane
      t.string :file_remote_path
      t.text :file_info
      t.text :file_info_raw
      t.timestamps
    end
  end
end
