class CreateAskCompletes < ActiveRecord::Migration
  def change
    create_table :ask_completes do |t|
      t.integer :user_id
      t.integer :ask_id
      t.integer :ask_deal_id
      t.integer :star_point, :default => 0

      t.timestamps null: false
    end
    remove_column :asks, :be_completed, :boolean
  end
end
