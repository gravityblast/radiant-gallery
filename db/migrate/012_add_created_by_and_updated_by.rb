class AddCreatedByAndUpdatedBy < ActiveRecord::Migration
  def self.up     
    add_column :galleries, :created_by, :integer
    add_column :galleries, :updated_by, :integer
    add_column :gallery_items, :created_by, :integer
    add_column :gallery_items, :updated_by, :integer
  end
  
  def self.down
    remove_column :galleries, :created_by
    remove_column :galleries, :updated_by
    remove_column :gallery_items, :created_by
    remove_column :gallery_items, :updated_by
  end
end