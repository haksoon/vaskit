class RenameAlramsToAlarms < ActiveRecord::Migration
  def change
    rename_table :alrams, :alarms
    rename_column :alarms, :alram_type, :alarm_type
    rename_column :users, :alram_1, :alarm_1
    rename_column :users, :alram_2, :alarm_2
    rename_column :users, :alram_3, :alarm_3
    rename_column :users, :alram_4, :alarm_4
    rename_column :users, :alram_5, :alarm_5
    rename_column :users, :alram_6, :alarm_6
  end
end
