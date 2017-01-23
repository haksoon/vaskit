class CreateCollectionKeywords < ActiveRecord::Migration
  def change
    create_table :collection_keywords do |t|
      t.string :keyword, null: false
      t.integer :refer_count, default: 0, null: false

      t.timestamps null: false
    end

    create_table :collection_to_collection_keywords do |t|
      # t.integer :collection_id
      # t.integer :collection_keyword_id
      t.references :collection, null: false
      t.references :collection_keyword, null: false

      t.timestamps null: false
    end
  end
end
