class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :ask_id
      t.string :title
      t.text :url

      t.timestamps null: false
    end
  end
end
