class GalleryItemsController < ApplicationController
  
  helper 'galleries'
  layout false
  
  before_filter :find_gallery
  before_filter :find_item, :only => [:show, :edit, :update, :destroy, :move]
         
  def index
  end   
  
  def show
  end
  
  def new
    respond_to do |format|
      format.html { render :layout => 'gallery_popup' }
    end
  end
  
  def create                 
    if params[:gallery_item] && params[:gallery_item][:uploaded_data].size > 0
      @item = @gallery.items.create(params[:gallery_item])      
      respond_to do |format|
        format.html do
          flash[:notice] = "Your file has been saved below."
          redirect_to admin_gallery_url(@gallery)          
        end
        format.xml  { render :xml => @item, :status => :created }
        format.js   { @created = true; headers['Content-Type'] = 'text/html'; render :template => 'gallery_items/create.html.erb' }
      end
    else      
      respond_to do |format|
        format.html do 
          flash[:error] = "I had troubles uploading your file :("
          render :action => 'new'
        end
        format.js   { @created = false; headers['Content-Type'] = 'text/html'; render :template => 'gallery_items/create.html.erb' }
        # TODO: format.xml
      end
    end    
  rescue ActiveRecord::RecordNotFound
    redirect_to(gallery_index_url)
  end
  
  def edit
    #unless request.xhr?
    #  redirect_to(gallery_show_url(:id => @item.gallery.id)) and return
    #end
  end
  
  def update
    @updated = @item.update_attributes(params[:gallery_item])

    respond_to do |format|
      format.js
    end
  end
  
  def destroy  
    @destroyed = @item.destroy
    
    respond_to do |format|
      format.html { redirect_to admin_gallery_url(@gallery) }
      format.js
    end
  end     
  
  def move
    old_position, new_position = params[:old_position].to_i, params[:new_position].to_i
    if @item.position == old_position
      x, y, z = old_position < new_position ? ["-", "<", ">"] : ["+", ">", "<"]
      GalleryItem.update_all("position = (position #{x} 1)", ["parent_id IS NULL AND gallery_id = ? AND position #{y}= ? AND position #{z}= ?", @item.gallery_id, new_position, old_position])
      @item.update_attribute('position', new_position)
    else
      @error = true
    end
    
    respond_to do |format|
      format.js
      format.xml { head :ok }
    end
  end
  
private

  def find_item    
    @item = @gallery.items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to admin_gallery_url(@gallery) }
      format.js   { render :partial => 'not_found' }
    end
  end          
  
  def find_gallery    
    @gallery = Gallery.find(params[:gallery_id])    
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_galleries_url
  end
  
end
