class AddColumnToUserGcmKeys < ActiveRecord::Migration
  def change
    add_column :user_gcm_keys, :device_id, :string
  end
end
