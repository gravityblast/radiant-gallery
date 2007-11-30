class AddParentIdToGallery < ActiveRecord::Migration
  def self.up
    add_column :galleries, :parent_id, :integer
  end
  
  def self.down
    remove_column :galleries, :parent_id
  end
end
