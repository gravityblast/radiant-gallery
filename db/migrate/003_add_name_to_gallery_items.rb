class AddNameToGalleryItems < ActiveRecord::Migration
  def self.up
    add_column :gallery_items, :name, :string
  end
  
  def self.down
    remove_column :gallery_items, :name
  end
end