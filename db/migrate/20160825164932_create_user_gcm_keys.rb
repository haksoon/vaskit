class CreateUserGcmKeys < ActiveRecord::Migration
  def change
    create_table :user_gcm_keys do |t|
      t.integer :user_id
      t.string :gcm_key

      t.timestamps null: false
    end
  end
end
