class RemoveAdminChoiceFromAsks < ActiveRecord::Migration
  def up
    remove_column :asks, :admin_choice
    change_column :videos, :fb_id, :string
    add_column :events, :label, :boolean, default: true
  end
  def down
    add_column :asks, :admin_choice, :integer, default: 0
    change_column :videos, :fb_id, :text
    remove_column :events, :label
  end
end
