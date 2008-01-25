class Gallery < ActiveRecord::Base
  
  acts_as_tree :counter_cache => :children_count
           
  # TODO: add :order => :position
  has_many :items, :class_name => 'GalleryItem', :order => "gallery_items.position", :dependent => :destroy,
    :conditions => "gallery_items.parent_id IS NULL"
    
  has_many :images, :through => :items, :source => :gallery,
    :conditions => "content_type LIKE '%image%'"    

  has_many :files, :through => :items, :source => :gallery,
    :conditions => "content_type NOT LIKE '%image%'"    
  
  has_many :thumbnails, :class_name => 'GalleryItem',
    :conditions => "gallery_items.parent_id IS NOT NULL"
    
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :update_by, :class_name => 'User', :foreign_key => 'update_by'
      
  attr_protected :slug, :path    
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :parent_id
                 
  # Filters
  before_save :set_slug
  after_create :set_path
  before_destroy :unlink_folder

  has_many :pages, :foreign_key => 'base_gallery_id', :dependent => :nullify
  
  def clear_thumbs
    self.thumbnails.find(:all, :conditions => "thumbnail NOT LIKE 'admin_%'").each do |item|
      item.destroy
    end
  end
  
  def thumbs_path
    File.join(self.path, 'thumbs')
  end
  
  def absolute_path
    File.join(RAILS_ROOT, 'public', self.path)
  end
  
  def absolute_thumbs_path
    File.join(self.absolute_path, 'thumbs')
  end
  
  def url(root_id = nil)
    File.join((self.ancestors_from(root_id).reverse << self).collect{|a| a.slug})
  end
  
  def ancestors_from(root_id = nil)
    ancestors = []
    (self.ancestors).each do |a|      
      break if a.id == root_id
      ancestors << a
    end
    ancestors
  end
  
protected

  def set_slug
    self.slug = self.name.downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').strip.gsub(/[\s\.:;=+]+/, '-')
  end
  
  def set_path
    galleries_folder = Radiant::Config['gallery.path'] || 'galleries'
    self.update_attribute(:path, File.join(galleries_folder, self.id.to_s))
  end
  
  def unlink_folder
    FileUtils.rm_rf(self.absolute_path)
  end
  
end
