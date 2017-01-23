class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name
      t.text :description
      t.boolean :show, :default => false
      t.timestamps null: false
    end
  end
end
