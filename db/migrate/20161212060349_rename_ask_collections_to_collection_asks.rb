class RenameAskCollectionsToCollectionAsks < ActiveRecord::Migration
  def change
    rename_table :ask_collections, :collection_to_asks
    add_column :collection_to_asks, :seq, :integer

    rename_table :error_logs, :log_errors
    rename_table :mail_logs, :log_mails
    rename_table :inquiries, :log_inquiries
    rename_table :reports, :log_reports
  end
end
