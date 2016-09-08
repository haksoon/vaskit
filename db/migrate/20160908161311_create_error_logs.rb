class CreateErrorLogs < ActiveRecord::Migration
  def change
    create_table :error_logs do |t|
      t.integer :user_id
      t.integer :visitor_id
      t.text :error
      t.text :error_href
      t.text :user_agent
      t.text :error_message
      t.text :error_url
      t.text :error_line
      t.text :error_col

      t.timestamps null: false
    end
  end
end
