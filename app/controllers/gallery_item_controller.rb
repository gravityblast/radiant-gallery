class GalleryItemController < ApplicationController
    
  before_filter :find_item, :except => [ :create, :sort ]
  
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
  
end
