class CreateSearchLogs < ActiveRecord::Migration
  def change
    create_table :search_logs do |t|
      t.string :keyword, null: false
      t.string :search_type, null: false
      t.datetime :created_at, null: false
    end

    create_table :search_keywords do |t|
      t.string :keyword, null: false
      t.string :search_type, null: false
      t.integer :list_order, null: false
    end
  end
end
