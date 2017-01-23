class CreateAskCollections < ActiveRecord::Migration
  def change
    create_table :ask_collections do |t|
      t.integer :collection_id
      t.integer :ask_id
      t.timestamps null: false
    end
  end
end
