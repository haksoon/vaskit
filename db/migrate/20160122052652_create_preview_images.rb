class CreatePreviewImages < ActiveRecord::Migration
  def change
    create_table :preview_images do |t|
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
