class AddBaseGalleryIdToPages < ActiveRecord::Migration
  def self.up     
    add_column :pages, :base_gallery_id, :integer
  end
  
  def self.down
    remove_column :pages, :base_gallery_id   
  end
end