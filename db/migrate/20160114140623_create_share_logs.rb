class CreateShareLogs < ActiveRecord::Migration
  def change
    create_table :share_logs do |t|
      t.integer :user_id
      t.string :channel

      t.timestamps null: false
    end
  end
end
