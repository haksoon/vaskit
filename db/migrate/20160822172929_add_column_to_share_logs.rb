class AddColumnToShareLogs < ActiveRecord::Migration
  def change
    add_column :share_logs, :ask_id, :integer
  end
end
