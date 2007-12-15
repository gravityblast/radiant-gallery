class GalleryItemController < ApplicationController
  
  before_filter :find_item, :except => [:create, :sort]
  
  def create
    @gallery = Gallery.find(params[:gallery_id])
    if params[:gallery_item][:uploaded_data].size > 0
      @gallery.items.create(params[:gallery_item])
      flash[:notice] = "Your file has been saved below."
    else
      flash[:error] = "I had troubles uploading your file :("
    end
    redirect_to gallery_show_url(:id => @gallery)
  rescue ActiveRecord::RecordNotFound
    redirect_to(gallery_index_url)
  end
  
  def edit
    unless request.xhr?
      redirect_to(gallery_show_url(:id => @item.gallery.id)) and return
    end
  end
  
  def update
    if request.xhr? && request.post?
      @item.update_attributes params[:item]
    else
      redirect_to(gallery_show_url(:id => @item.gallery.id)) and return
    end
  end
  
  def destroy
    if request.xhr? && request.post?
      @destroyed = @item.destroy
    else
      redirect_to(gallery_show_url(:id => @item.gallery.id)) and return
    end    
  end
  
  def edit_image
    if request.post?
      case params[:edit_action]
      when 'crop'
        options = Hash[*params.find_all{|k, v| k =~ /^crop_/}.flatten!]
        crop_image(options)
        redirect_to gallery_show_url(:id => @gallery)
      end
    end
  end 
  
  def sort
    old_position, new_position = params[:old_position].to_i, params[:new_position].to_i
    @item = GalleryItem.find(:first, :conditions => ["id = ? AND position = ?", params[:id], old_position])
    if @item
      x, y, z = old_position < new_position ? ["-", "<", ">"] : ["+", ">", "<"]
      GalleryItem.update_all("position = (position #{x} 1)", ["parent_id IS NULL AND gallery_id = ? AND position #{y}= ? AND position #{z}= ?", @item.gallery_id, new_position, old_position])
      @item.update_attribute('position', new_position)
    else
      @error = true
    end
  end
  
private

  def find_item
    @item = GalleryItem.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to(gallery_index_url)
  end

  def crop_image(options)    
    @gallery = @item.gallery
    img = Magick::Image::read(File.join(RAILS_ROOT, 'public', @item.public_filename)).first
    gallery_absolute_path = File.join(RAILS_ROOT, 'public', @gallery.path)
    new_filename = suggest_name(gallery_absolute_path, File.basename(@item.public_filename))
    file_absolute_path = File.join(gallery_absolute_path, new_filename)
    square = img.crop(options['crop_x1'].to_i, options['crop_y1'].to_i, options['crop_width'].to_i, options['crop_height'].to_i)
    white_bg = Magick::Image.new(square.columns, square.rows)
    new_image = white_bg.composite(square, 0, 0, Magick::OverCompositeOp)
    new_image.write file_absolute_path    
    @gallery.items.create(:filename => File.basename(file_absolute_path), :content_type => @item.content_type )
    flash[:notice] = "Your file has been saved below."
  end
  
end
