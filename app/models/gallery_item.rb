class GalleryItem < ActiveRecord::Base    
  
  class KnownExtensions
    @@extensions = {}
    class << self
      def []=(extension, content_type)
        @@extensions[extension.downcase] = content_type
      end
      def [](extension)
        @@extensions[extension.downcase] || 'Unknown'
      end
    end
  end      
  
  attr_accessible :name, :description, :uploaded_data
  
  has_attachment :storage => :file_system,
    :path_prefix => Radiant::Config["gallery.path_prefix"],
    :processor => Radiant::Config["gallery.processor"]      
  
  belongs_to :gallery
  
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :update_by, :class_name => 'User', :foreign_key => 'update_by'
  
  belongs_to :parent, :class_name => 'GalleryItem', :foreign_key => 'parent_id'
  
  has_many :infos, :class_name => "GalleryItemInfo", :dependent => :delete_all

  before_create :set_filename_as_name
  before_create :set_position
  before_create :set_extension

  before_destroy :update_positions
  
  after_attachment_saved do |item|
    item.generate_default_thumbnails if item.parent.nil?
  end       
  
  before_thumbnail_saved do |thumbnail|
    thumbnail.gallery_id = thumbnail.parent.gallery_id
  end                                                
  
  def thumb(options = {})
    if self.thumbnailable?
      prefix    = options[:prefix] ? "#{options[:prefix]}_" : ''    
      if options[:special].compact.length > 0
        pre = options[:special][0] == null ? '' : options[:special][0] 
        post = options[:special][1] == null ? '' : options[:special][1] 
        size    = "#{pre}#{options[:width]}x#{options[:height]}#{post}"
        suffix    = "#{prefix}#{size}"      
      elsif options[:geometry] != nil
        size = options[:geometry]   
        suffix  = "#{prefix}#{size}"      
      else
        size    = proportional_resize(:max_width => options[:width], :max_height => options[:height])
        suffix    = "#{prefix}#{size[0]}x#{size[1]}"      
      end                        
      thumbnail = self.thumbnails.find_by_thumbnail(suffix)
      unless thumbnail
        temp_file = create_temp_file
        thumbnail = create_or_update_thumbnail(temp_file, suffix, size)
      end      
      thumbnail
    else
      self
    end
  end
  
  def jpeg?
    not (self.content_type =~ /jpeg/).nil?
  end
  
  def absolute_path
    File.expand_path(self.full_filename)
  end
  
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
    gallery_folder = self.gallery ? self.gallery.id.to_s : self.parent.gallery.id.to_s
    File.join(RAILS_ROOT, file_system_path, gallery_folder, *partitioned_path(thumbnail_name_for(thumbnail)))
  end
  
  def last?
    self.position ==  self.gallery.items.count
  end
  
  def generate_default_thumbnails      
    if self.thumbnailable? and default_thumbnails = Radiant::Config['gallery.default_thumbnails']
      default_thumbnails.split(',').each do |default_thumbnail|
         if default_thumbnail =~ /^(\w+)=([a-z])?(\d+)?x(\d+)?([%!<>@]?)$/
           prefix, pre_char, width, height, post_char = $1, $2, $3, $4, $5
           self.thumb(:width => width, :height => height, :prefix => prefix, :special => [pre_char, post_char])
        end
      end
    end
  end  
  
protected    

  def set_filename_as_name
    unless parent
      ext = File.extname(filename)
      filename_without_extension = filename[0, filename.size - ext.size]
      self.name = filename_without_extension
    end
  end 
  
  def set_position
    self.position = self.gallery.items.count + 1 unless parent
  end
  
  def set_extension
    self.extension = self.filename.split(".").last.to_s.downcase unless parent
  end      
  
  def update_positions
    if self.parent.nil?
      GalleryItem.update_all("position = (position - 1)", ["position > ? AND parent_id IS NULL and gallery_id = ?", self.position, self.gallery.id])
    end
  end
  
  def proportional_resize(options = {})
    max_width = options[:max_width] ? options[:max_width].to_f : width.to_f
    max_height = options[:max_height] ? options[:max_height].to_f : height.to_f    
    aspect_ratio, pic_ratio = max_width / max_height.to_f, width.to_f / height.to_f
    scale_ratio = (pic_ratio > aspect_ratio) ?  max_width / width : max_height / height  
    [(width * scale_ratio).to_i, (height * scale_ratio).to_i]    
  end
    
end
