class CreateReferLinks < ActiveRecord::Migration
  def change
    create_table :refer_links do |t|
      t.string :channel, null: false
      t.string :name, null: false
      t.string :commerce_type, null: false
      t.integer :commerce_budget, null: false, default: 0
      t.integer :commerce_expense, null: false, default: 0
      t.datetime :commerce_started_at
      t.datetime :commerce_ended_at
      t.string :url, null: false
      t.string :js, null: false
      t.boolean :connect_to_store, default: 0

      t.timestamps null: false
    end

    add_column :user_visits, :refer_link_id, :integer
  end
end
