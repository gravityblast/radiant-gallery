class AddExternalColumnInGalleriesTable < ActiveRecord::Migration
  def self.up
    add_column :galleries, :external, :boolean, :default => false
  end
  
  def self.down
    remove_column :galleries, :external
  end
end
