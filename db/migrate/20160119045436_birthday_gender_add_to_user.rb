class BirthdayGenderAddToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :birthday, :date
    add_column :users, :gender, :boolean
    add_column :users, :sign_up_type, :string
    add_column :users, :agree_access_term, :boolean
    
  end
end
