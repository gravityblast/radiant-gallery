class AddHiddenColumn < ActiveRecord::Migration
  def self.up
    add_column :galleries, :hidden, :boolean, :null => false, :default => false    
  end
  
  def self.down
    remove_column :galleries, :hidden
  end
end