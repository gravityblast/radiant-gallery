require 'tempfile'
require_dependency 'open-uri'
require_dependency 'exifr/jpeg'
require_dependency 'exifr/tiff'

class GalleryExtensionError < StandardError; end

class GalleryExtension < Radiant::Extension
  version "0.7.3"
  description "Allows to manage list of files/images grouped into galleries"
  url "http://gravityblast.com/projects/gor/"
  
  define_routes do |map|
    map.with_options(:controller => 'gallery') do |gallery|
      gallery.gallery_index           'admin/gallery',                            :action => 'index'
      gallery.gallery_new             'admin/gallery/new',                        :action => 'new'
      gallery.gallery_new_child       'admin/gallery/:parent_id/new',             :action => 'new'
      gallery.gallery_create          'admin/gallery/create',                     :action => 'create'
      gallery.gallery_create_child    'admin/gallery/:parent_id/create',          :action => 'create'
      gallery.gallery_edit            'admin/gallery/edit/:id',                   :action => 'edit'      
      gallery.gallery_update          'admin/gallery/update/:id',                 :action => 'update'
      gallery.gallery_show            'admin/gallery/show/:id',                   :action => 'show'
      gallery.gallery_destroy         'admin/gallery/destroy/:id',                :action => 'destroy'
      gallery.gallery_children        'admin/gallery/children/:id',               :action => 'children'      
      gallery.gallery_retrieve_file   'admin/gallery/retrieve_file',              :action => 'retrieve_file'      
      gallery.gallery_clear_thumbs    'admin/gallery/clear_thumbs/:id',           :action => 'clear_thumbs'      
      gallery.gallery_import          'admin/gallery/import/:id',                 :action => 'import'
    end
    map.with_options(:controller => 'gallery_item') do |gallery_item|
      gallery_item.gallery_item_create      'admin/gallery_item/create',          :action => 'create'
      gallery_item.gallery_item_edit        'admin/gallery_item/:id/edit',        :action => 'edit'
      gallery_item.gallery_item_update      'admin/gallery_item/update/:id',      :action => 'update'
      gallery_item.gallery_item_destroy     'admin/gallery_item/:id/destroy',     :action => 'destroy'
      gallery_item.gallery_item_edit_image  'admin/gallery_item/:id/edit_image',  :action => 'edit_image'
      gallery_item.gallery_item_sort        'admin/gallery_item/sort',            :action => 'sort'            
    end
  end
  
  def activate    
    GalleryPage
    GalleryCachedPage
    admin.tabs.add "Galleries", "/admin/gallery", :after => "Layouts", :visibility => [:all]
    Page.send :include, GalleryTags, GalleryItemTags, GalleryItemInfoTags, GalleryLightboxTags
    
    # AttachmentFu
    Tempfile.class_eval do
      # overwrite so tempfiles use the extension of the basename.  important for rmagick and image science
      def make_tmpname(basename, n)
        ext = nil
        sprintf("%s%d-%d%s", basename.to_s.gsub(/\.\w+$/) { |s| ext = s; '' }, $$, n, ext)
      end
    end        
    
    ActiveRecord::Base.send(:extend, Technoweenie::AttachmentFu::ActMethods)
    Technoweenie::AttachmentFu.tempfile_path = ATTACHMENT_FU_TEMPFILE_PATH if Object.const_defined?(:ATTACHMENT_FU_TEMPFILE_PATH)
    FileUtils.mkdir_p Technoweenie::AttachmentFu.tempfile_path        
    load_gallery_configuration
    load_content_types
  end
  
  def deactivate
    admin.tabs.remove "Galleries"
  end
  
  def load_gallery_configuration    
    filename = File.join(GalleryExtension.root, 'config', 'gallery.yml')
    raise GalleryExtensionError.new("GalleryExtension error: configuration file does not exist. Rename gallery.yml.default to gallery.yml.") unless File.exists?(filename)
    configurations = YAML::load_file(filename)
    configurations.each do |key, value|
      Radiant::Config["gallery.#{key}"] = value
    end
  end
  
  def load_content_types
   filename = File.join(GalleryExtension.root, 'config', 'content_types.yml')
    content_types = YAML::load_file(filename)
    content_types.each do |name, attributes|
      attributes["extensions"].each do |extension|
        GalleryItem::KnownExtensions[extension] = {
          :content_type => name,
          :icon => attributes["icon"]
        }
      end
    end    
  end
    
end