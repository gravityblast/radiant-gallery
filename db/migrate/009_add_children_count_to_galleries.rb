class AddChildrenCountToGalleries < ActiveRecord::Migration
  def self.up
    add_column :galleries, :children_count, :integer, :null => false, :default => 0
    Gallery.find(:all).each do |gallery|
      gallery.update_attribute(:children_count, gallery.children.count)
    end
  end
  
  def self.down
    remove_column :galleries, :children_count
  end
end