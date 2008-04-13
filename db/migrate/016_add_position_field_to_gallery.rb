class AddPositionFieldToGallery < ActiveRecord::Migration
  def self.up
    add_column :galleries, :position, :integer
  end
  
  def self.down
    remove_column :galleries, :position
  end
end
