class AddAppVerToUserGcmKeys < ActiveRecord::Migration
  def change
    add_column :user_gcm_keys, :app_ver, :string
  end
end
