class Spec1ToAsk < ActiveRecord::Migration
  def change
    add_column :asks, :spec1, :string
    add_column :asks, :spec2, :string
    add_column :asks, :spec3, :string
  end
end
