class CreateGalleryExtensionSchema < ActiveRecord::Migration
  def self.up
    
    create_table :galleries do |t|
      t.column :name, :string
      t.column :nicename, :string
      t.column :path, :string
      t.column :description, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    create_table :gallery_items do |t|
      t.column :filename, :string
      t.column :content_type, :string
      t.column :description, :string
      t.column :gallery_id, :integer
      t.column :position, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    Radiant::Config['galleries.path'] = 'galleries'
    
  end
  
  def self.down
    drop_table :galleries
    drop_table :gallery_items
  end
end