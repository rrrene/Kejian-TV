class CreateCoursewares < ActiveRecord::Migration
  def change
    create_table :coursewares do |t|

      t.timestamps
    end
  end
end
