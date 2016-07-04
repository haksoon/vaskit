class AddColumnToInquiries < ActiveRecord::Migration
  def change
    add_column :inquiries, :contact, :string
  end
end
