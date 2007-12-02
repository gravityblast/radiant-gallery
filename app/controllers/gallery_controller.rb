class GalleryController < ApplicationController
  
  def index    
    list
    render :action => 'list'
  end

  def list
    @galleries = Gallery.find(:all, :conditions => ["parent_id IS NULL"] )
  end

  def show
    @gallery = Gallery.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to(gallery_index_url)
  end

  def retrieve_file
    @gallery = Gallery.find_by_id(params[:id])    
    @file_url = params[:file_url]
    uri = URI.parse @file_url
    raise "You can specify only HTTP and FTP url using file url mode." unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::FTP)
    open(@file_url) do |remote_file|
      #file_path = File.join(RAILS_ROOT, 'public', @gallery.path, File.basename(@file_url))
      #file_extension = File.extname(file_path)
      #path_without_extension = file_path[0, file_path.size - file_extension.size]
      #file_path = "#{path_without_extension}#{file_extension.split('?')[0]}"
      #File.open(file_path, 'w') do |file|
      #  file.write remote_file.read
      #end
      #content_type = remote_file.respond_to?(:content_type)  ? remote_file.content_type : 'Undefined content type'
      #@gallery.items.create(:filename => File.basename(file_path), :content_type => content_type )
      @gallery.items.create(:uploaded_data => remote_file)
      flash[:notice] = "Your file has been saved below."
    end    
  rescue Exception => e
    flash[:error] = "I had troubles retrieving your file :( -  #{e}"    
  ensure
    redirect_to gallery_show_url(:id => @gallery)
  end
  
  def edit
    @gallery = Gallery.find_by_id(params[:id]) || Gallery.new
    if request.post?      
      @gallery.attributes = params[:gallery]
      @gallery.parent_id = params[:parent_id] if params[:parent_id]
      if @gallery.save        
        flash[:notice] = "Your gallery has been saved below."
        if params[:continue]
          redirect_to gallery_edit_url(:id => @gallery.id)
        else
          redirect_to gallery_show_url(:id => @gallery.id)
        end
      else
        flash[:error] = "Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing."
      end
    end
  end

  def remove
    @gallery = Gallery.find_by_id(params[:id])
    if request.post?
      count = @gallery.items.count
      @gallery.destroy
      flash[:notice] = if count > 1
        "The gallery and its images were successfully removed from the site."
      else
        "The gallery and its image was successfully removed from the site."
      end      
      redirect_to gallery_index_url
    end
  end    

  def clear_thumbs
    @gallery = Gallery.find(params[:id])
    @gallery.clear_thumbs
    flash[:notice] = 'Thumbnails have been deleted correctly'
    redirect_to(gallery_show_url(:id => @gallery))
  rescue ActiveRecord::RecordNotFound
    redirect_to(gallery_index_url)
  end
  
  def children
    @gallery = Gallery.find(params[:id])    
    render(:layout => false)
  end
  
  def import
    @gallery = Gallery.find_by_id(params[:id]) or (redirect_to(gallery_index_url) and return)     
    import_path = File.join(galleries_absolute_path, 'import')
    @folders = Dir[File.join(import_path, '**',  '*')].find_all{|path| path if File.directory?(path)  }
    @folders << import_path
    @folders.collect!{|path| path.gsub(/^#{galleries_absolute_path}/, '')}.sort!
    if request.post?
      @confirmed = true
      @selected_path = File.expand_path(File.join(galleries_absolute_path, params[:path]))      
      if @selected_path =~ /^#{import_path}/
        @files = Dir[File.join(@selected_path, '**', '*')].find_all{|file| file if File.file?(file)}
        @files.collect!{|file| file.gsub(/^#{galleries_absolute_path}/, '')}.sort!
      end
    end
  end
  
  def importing
    if request.post?            
      @gallery = Gallery.find_by_id(params[:id])
      import_path = File.join(galleries_absolute_path, 'import')
      path = File.expand_path(File.join(galleries_absolute_path, params[:path]))      
      if path =~ /^#{import_path}/ and File.exists?(path)
        tmp_file = GalleryItem.copy_to_temp_file path, "#{rand Time.now.to_i}#{File.basename(path)}"
        item = GalleryItem.new
        item.attributes = {
          :gallery_id => @gallery.id,
          :temp_path => tmp_file,
          :filename => File.basename(path),
          :content_type => GalleryItem::KnownExtensions[File.extname(path).gsub(/^\./, '')][:content_type]
        }
        FileUtils.rm(path)
        item.save
        [300, 500].each{|size| item.thumb(:width => size, :height => size, :prefix => 'admin')}
        @imported = true
      end
    else
      redirect_to gallery_index_url
    end
  end    
    
private  
  
  def galleries_absolute_path
    galleries_folder = Radiant::Config['gallery.path'] || 'galleries'
    galleries_path = File.expand_path(File.join(RAILS_ROOT, 'public', galleries_folder))    
  end
  
end
