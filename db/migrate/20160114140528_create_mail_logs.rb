class CreateMailLogs < ActiveRecord::Migration
  def change
    create_table :mail_logs do |t|
      t.integer :user_id
      t.text :content

      t.timestamps null: false
    end
  end
end
