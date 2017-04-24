class AddPublishedAtToCollections < ActiveRecord::Migration
  def up
    add_column :collections, :published_at, :datetime
    add_column :videos, :published_at, :datetime

    Collection.all.each do |collection|
      next unless collection.show
      collection.update_columns(published_at: collection.updated_at)
    end

    Video.all.each do |video|
      next unless video.show
      video.update_columns(published_at: video.updated_at)
    end

    remove_column :collections, :show
    remove_column :videos, :show
  end

  def down
    remove_column :collections, :published_at
    remove_column :videos, :published_at
    add_column :collections, :show, :boolean
    add_column :videos, :show, :boolean
  end
end
