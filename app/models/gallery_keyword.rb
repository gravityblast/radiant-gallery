class GalleryKeyword < ActiveRecord::Base
  has_and_belongs_to_many :gallery_items, :join_table => "gallery_items_keywords", :foreign_key => "keyword_id", :uniq => true,
                            :class_name => "GalleryItem", :association_foreign_key => "gallery_item_id"
  has_and_belongs_to_many :galleries, :join_table => "galleries_keywords", :foreign_key => "keyword_id", :uniq => true,
                            :class_name => "Gallery", :association_foreign_key => "gallery_id"                      
end       