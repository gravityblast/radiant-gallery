class CreateGalleryImportings < ActiveRecord::Migration
  def self.up
    create_table :gallery_importings do |t|
      t.integer :gallery_id
      t.string  :path
      t.timestamps
    end
  end

  def self.down
    drop_table :gallery_importings
  end
end
