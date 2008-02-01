class ChangeGalleriesDescriptionColumnToText < ActiveRecord::Migration
  def self.up
    change_column :galleries, :description, :text
  end
  
  def self.down
    change_column :galleries, :description, :string
  end
end
