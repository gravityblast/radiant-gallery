class CreateGalleryImportings < ActiveRecord::Migration
  def self.up
    create_table :gallery_importings do |t|
      t.column :gallery_id, :integer
      t.column :path, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :gallery_importings
  end
end
