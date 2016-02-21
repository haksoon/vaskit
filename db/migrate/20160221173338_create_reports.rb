class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :report_type
      t.string :message
      t.string :target
      t.integer :target_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
