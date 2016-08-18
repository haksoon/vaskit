class AddCoulumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :alram_1, :boolean, :default => 1
    add_column :users, :alram_2, :boolean, :default => 1
    add_column :users, :alram_3, :boolean, :default => 1
    add_column :users, :alram_4, :boolean, :default => 1
    add_column :users, :alram_5, :boolean, :default => 1
    add_column :users, :alram_6, :boolean, :default => 1
    add_column :alrams, :comment_owner_user_id, :integer
    add_column :alrams, :comment_id, :integer
  end
end
