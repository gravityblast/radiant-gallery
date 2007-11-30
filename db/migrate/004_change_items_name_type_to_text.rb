class ChangeItemsNameTypeToText < ActiveRecord::Migration
  def self.up
    change_column :gallery_items, :description, :text
  end
  
  def self.down
    change_column :gallery_items, :description, :string
  end
end
