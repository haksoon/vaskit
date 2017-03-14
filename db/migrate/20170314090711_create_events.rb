class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :ask_id, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at, null: false
      t.attachment :image, null: false
    end

    add_column :asks, :event_id, :integer
  end
end
