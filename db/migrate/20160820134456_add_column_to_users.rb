class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_role, :string, :default => "user"
  end
end
