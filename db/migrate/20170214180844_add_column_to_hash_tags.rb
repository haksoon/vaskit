class AddColumnToHashTags < ActiveRecord::Migration
  def change
    add_column :hash_tags, :comment_id, :integer
  end
end
