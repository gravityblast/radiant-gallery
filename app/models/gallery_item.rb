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
  
  has_attachment :storage => :file_system,
    :path_prefix => Radiant::Config["gallery.path_prefix"],
    :processor => Radiant::Config["gallery.processor"]
  
  acts_as_list :scope => :gallery

  belongs_to :gallery
  
  has_many :infos, :class_name => "GalleryItemInfo", :dependent => :delete_all

  before_create :set_filename_as_name
  before_create :set_position
  before_create :set_extension
  before_create :set_gallery_id_if_is_a_thumbnails    
   
  def jpeg?
    not (self.content_type =~ /jpeg/).nil?
  end
  
  def absolute_path
    File.expand_path(self.full_filename)
  end
  
  def thumb(options = {})
    thumbnail_options = {}
    if options[:width] or options[:height]      
      thumbnail_options[:suffix] = "#{options[:prefix] ? options[:prefix].to_s + '_' : ''}#{options[:width]}x#{options[:height]}"
      thumbnail_options[:size] = "#{options[:width]}x#{options[:height]}"      
    end
    if respond_to?(:process_attachment_with_processing) && thumbnailable? && parent_id.nil?
      tmp_thumb = find_or_initialize_thumbnail(thumbnail_options[:suffix])
      if tmp_thumb.new_record?
        logger.debug("Generating thumbnail(GalleryItem ID: #{self.id}: Prefix: #{thumbnail_options[:suffix]})")
        tmp_thumb.attributes = {
          :content_type             => content_type, 
          :filename                 => thumbnail_name_for(thumbnail_options[:suffix]), 
          :temp_path                => create_temp_file,
          :thumbnail_resize_options => thumbnail_options[:size]
        }
        callback_with_args :before_thumbnail_saved, tmp_thumb
        tmp_thumb.save!        
      else
        logger.debug("Thumbnail already exists (GalleryItem ID: #{self.id}: Prefix: #{thumbnail_options[:suffix]})")
      end
    end       
    tmp_thumb || self
  end    
  
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
    gallery_folder = self.gallery ? self.gallery.id.to_s : self.parent.gallery.id.to_s
    File.join(RAILS_ROOT, file_system_path, gallery_folder, *partitioned_path(thumbnail_name_for(thumbnail)))
  end
    
protected    

  def set_filename_as_name
    ext = File.extname(filename)
    filename_without_extension = filename[0, filename.size - ext.size]
    self.name = filename_without_extension
  end 
  
  def set_position
    self.position = 0 if self.gallery && self.gallery.items.size == 0
  end
  
  def set_extension
    self.extension = self.filename.split(".").last.to_s.downcase
  end      
    
  def set_gallery_id_if_is_a_thumbnails
    self.gallery = self.parent.gallery if self.parent    
  end  
    
end
