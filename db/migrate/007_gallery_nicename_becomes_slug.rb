class GalleryNicenameBecomesSlug < ActiveRecord::Migration
  def self.up
    rename_column :galleries, :nicename, :slug
  end
  
  def self.down
    rename_column :galleries, :slug, :nicename
  end
end