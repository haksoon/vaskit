class CreateNotices < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.string :title
      t.text :message

      t.timestamps null: false
    end
    add_column :users, :receive_notice_email, :boolean, :default => true
  end
end
