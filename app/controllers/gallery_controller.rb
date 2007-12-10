class GalleryController < ApplicationController
  
  before_filter :find_gallery, :except => [:index, :list, :new, :create]
  
  def index    
    @galleries = Gallery.find(:all, :conditions => ["parent_id IS NULL"] )
  end

  def new
    @gallery = Gallery.new    
  end
  
  def create
    if request.post?
      @gallery = Gallery.new(params[:gallery].merge({:parent_id => params[:parent_id]}))
      if @gallery.save
        flash[:notice] = "Your gallery has been saved below." 
        redirect_to( params[:continue] ? gallery_edit_url(:id => @gallery.id) : gallery_show_url(:id => @gallery.id))
      else
        flash[:error] = "Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing."
        render(:action => 'new')
      end
    else
      redirect_to(gallery_index_url)
    end
  end
  
  def edit    
  end
  
  def update
    if request.post?
      if @gallery.update_attributes(params[:gallery])
        flash[:notice] = "Your gallery has been saved below."
        redirect_to( params[:continue] ? gallery_edit_url(:id => @gallery.id) : gallery_show_url(:id => @gallery.id))
      else
        flash[:error] = "Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing."
        render(:action => 'edit')
      end
    else
      redirect_to(gallery_edit_url(:id => @gallery))
    end
  end
  
  def destroy
    if request.post?
      count = @gallery.items.count
      @gallery.destroy
      flash[:notice] = if count > 1
        "The gallery and its images were successfully destroyed from the site."
      else
        "The gallery and its image was successfully destroyed from the site."
      end      
      redirect_to(gallery_index_url)
    end
  end
  
  def retrieve_file
    @file_url = params[:file_url]
    uri = URI.parse(@file_url)
    raise "You can specify only HTTP and FTP url using file url mode." unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::FTP)
    temp_file_path = File.join(Technoweenie::AttachmentFu.tempfile_path, File.basename(@file_url.gsub(/\?.*$/, '')))
    open(@file_url) do |remote_file|      
      File.open(temp_file_path, 'w') do |file|
        file.write(remote_file.read)
      end                  
    end
    create_item(@gallery, temp_file_path)
    flash[:notice] = "Your file has been saved below."    
  rescue Exception => e
    flash[:error] = "I had troubles retrieving your file :( -  #{e}"    
  ensure
    redirect_to gallery_show_url(:id => @gallery)
  end    

  def clear_thumbs
    @gallery.clear_thumbs
    flash[:notice] = 'Thumbnails have been deleted correctly'
    redirect_to(gallery_show_url(:id => @gallery))
  end
  
  def children
    render(:layout => false)
  end
  
  def import
    @folders = import_folders    
    if request.post? && params[:file_path]
      path = File.expand_path(File.join(galleries_absolute_path, params[:file_path]))     
      if path =~ /^#{import_path}/ and File.exists?(path)
        create_item(@gallery, path)
        @imported = true
      end
      render(:action => 'imported')
    elsif request.post?
      @files = []
      @selected_path = File.expand_path(File.join(galleries_absolute_path, params[:path]))
      if @selected_path =~ /^#{import_path}/
        @files = Dir[File.join(@selected_path, '**', '*')].find_all{|file| file if File.file?(file)}
        @files.collect!{|file| file.gsub(/^#{galleries_absolute_path}/, '')}.sort!
        render(:action => 'import_files')
      end
    end
  end        
    
private  
  
  def find_gallery
    @gallery = Gallery.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to(gallery_index_url)
  end
  
  def galleries_absolute_path
    galleries_folder = Radiant::Config['gallery.path_prefix']
    galleries_path = File.expand_path(File.join(RAILS_ROOT, galleries_folder))    
  end

  def create_item(gallery, temp_path)
    item = GalleryItem.new
    item.attributes = {
      :gallery_id => gallery.id,
      :temp_path => temp_path,
      :filename => File.basename(temp_path),
      :content_type => GalleryItem::KnownExtensions[File.extname(temp_path).gsub(/^\./, '')][:content_type]
    }    
    item.save
    FileUtils.rm(temp_path)
    if item.thumbnailable?
      [300, 500].each{|size| item.thumb(:width => size, :height => size, :prefix => 'admin')}
    end
  end
  
  def import_folders
    folders = Dir[File.join(import_path, '**',  '*')].find_all{|path| path if File.directory?(path)  }
    folders << import_path
    folders.collect!{|path| path.gsub(/^#{galleries_absolute_path}/, '')}.sort!
  end
  
  def import_path
    File.join(galleries_absolute_path, 'import')
  end
  
end
