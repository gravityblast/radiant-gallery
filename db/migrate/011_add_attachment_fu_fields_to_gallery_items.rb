class AddAttachmentFuFieldsToGalleryItems < ActiveRecord::Migration
  def self.up     
    add_column :gallery_items, :size,       :integer  
    add_column :gallery_items, :height,     :integer  
    add_column :gallery_items, :width,      :integer  
    add_column :gallery_items, :parent_id,  :integer  
    add_column :gallery_items, :thumbnail,  :string
  end
  
  def self.down
    remove_column :gallery_items, :size
    remove_column :gallery_items, :height
    remove_column :gallery_items, :width
    remove_column :gallery_items, :parent_id
    remove_column :gallery_items, :thumbnail
  end
end