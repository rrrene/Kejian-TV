class AddLangToCourseware < ActiveRecord::Migration
  def change
    add_column :coursewares, :lang, :string
  end
end
