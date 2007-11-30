class AddExtensionToGalleryItem < ActiveRecord::Migration
  def self.up
    add_column :gallery_items, :extension, :string
    GalleryItem.find(:all).each do |item|
      ext = File.extname(item.filename)
      item.extension = ext.split(".")[1].to_s.downcase
      item.save
    end
  end
  
  def self.down
    remove_column :gallery_items, :extension
  end
end