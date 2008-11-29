require 'action_controller/test_process.rb'

class GalleryImportingsController < ApplicationController
  
  helper 'galleries'
  layout 'gallery_popup'  
  
  before_filter :find_gallery
  
  def index
    @importings = @gallery.importings
  end
  
  def new
    @folders = import_folders
    @importing = GalleryImporting.new
  end
  
  def create
    selected_path = File.expand_path(File.join(galleries_absolute_path, params[:path]))
    if selected_path =~ /^#{import_path}/ and File.exists?(selected_path)
      params[:recursive] ? recursive_importing(@gallery, selected_path) : import_files(@gallery, selected_path)
    end
    
    respond_to do |format|
      format.html { redirect_to admin_gallery_importings_url(@gallery) }
    end
  end
  
  def import
    @importing = @gallery.importings.find(params[:id])
    @item = create_item(@gallery, @importing.path)
    @importing.destroy
    
    respond_to do |format|
      format.js
    end
  end
  
private  

  def find_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end
  
  def galleries_absolute_path
    galleries_folder = Radiant::Config['gallery.path_prefix']
    galleries_path = File.expand_path(File.join(RAILS_ROOT, galleries_folder))    
  end
  
  def import_folders
    folders = Dir[File.join(import_path, '**',  '*')].find_all{|path| path if File.directory?(path)  }
    folders << import_path
    folders.collect!{|path| path.gsub(/^#{galleries_absolute_path}/, '')}.sort!
  end
  
  def import_path
    File.join(galleries_absolute_path, 'import')
  end
  
  def create_item(gallery, temp_path)
    return unless File.file?(temp_path)
    mimetype = GalleryItem::KnownExtensions[File.extname(temp_path).gsub(/^\./, '')][:content_type]
    @item = GalleryItem.new(
      :uploaded_data => ActionController::TestUploadedFile.new(temp_path, mimetype)
    )
    @item.gallery = gallery
    @item.save
    FileUtils.rm(temp_path)    
  end
  
  def recursive_importing(gallery, path)
    directories = Dir[File.join(path, '*')].find_all{|file| file if File.directory?(file)}
    import_files(gallery, path)
    directories.each do |directory|
      name = File.basename(directory)
      new_gallery = Gallery.find_or_initialize_by_parent_id_and_name(gallery.id, name)
      new_gallery.save
      recursive_importing(new_gallery, directory)
    end
  end
  
  def import_files(gallery, path)    
    files = Dir[File.join(path, '*')].find_all{|file| file if File.file?(file)}    
    files.each do |file|
      importing = GalleryImporting.find_or_initialize_by_gallery_id_and_path(gallery.id, file)
      importing.save
    end
  end
  
end
