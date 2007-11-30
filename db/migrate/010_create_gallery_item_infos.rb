class CreateGalleryItemInfos < ActiveRecord::Migration
  def self.up
    create_table :gallery_item_infos do |t|
      t.column :gallery_item_id, :integer
      t.column :name, :string
      t.column :value_string, :string
      t.column :value_text, :text
      t.column :value_integer, :integer
      t.column :value_datetime, :datetime
    end
    
  end

  def self.down
    drop_table :gallery_item_infos
  end
end
