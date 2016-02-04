class UniqKeyToVisitor < ActiveRecord::Migration
  def change
    add_column :visitors, :uniq_key, :string
    add_column :votes, :visitor_id, :integer
    add_column :votes, :ask_id, :integer
    add_column :comments, :ask_id, :integer
  end
end
