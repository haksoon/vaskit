class AddIsDeletedToLikes < ActiveRecord::Migration
  def change
    add_column :ask_likes, :is_deleted, :boolean, default: false
    add_column :comment_likes, :is_deleted, :boolean, default: false
    add_column :votes, :is_deleted, :boolean, default: false
    add_column :users, :alarm_7, :boolean, default: true
    remove_column :users, :is_deleted
  end
end
