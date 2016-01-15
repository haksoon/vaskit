class CreateHashTags < ActiveRecord::Migration
  def change
    create_table :hash_tags do |t|
      t.integer :ask_id
      t.integer :user_id
      t.string :keyword

      t.timestamps null: false
    end
  end
end
