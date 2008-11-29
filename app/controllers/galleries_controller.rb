class GalleriesController < ApplicationController
  helper :gallery_items
  before_filter :find_gallery, :except => [:index, :list, :new, :create, :reorder, :update_order]
  
  def index
    conditions = params.include?(:parent_id) ? ["parent_id = ?", params[:parent_id]] : "parent_id IS NULL"
    @galleries = Gallery.find(:all, :conditions => conditions, :order => 'position')
    
    respond_to do |format|
      format.html { render :layout => !params.include?(:parent_id), :action => params.include?(:parent_id) ? 'children' : 'index' }
      format.xml { render :xml => @galleries }
    end
  end
  
  def show
    respond_to do |format|    
      format.html
      format.xml { render :xml => @gallery }
    end
  end
  
  def new
    @gallery = Gallery.new    

    respond_to do |format|    
      format.html
      format.xml { render :xml => @gallery }
    end
  end
  
  def create
    @gallery = Gallery.new(params[:gallery].merge({:parent_id => params[:parent_id]}))
    
    respond_to do |format|
      if @gallery.save
        flash[:notice] = "Your gallery has been saved below." 
        format.html { redirect_to( params[:continue] ? edit_admin_gallery_url(@gallery) : admin_gallery_url(@gallery)) }
        format.xml  { render :xml => @gallery, :status => :created, :location => @gallery }
      else
        flash[:error] = "Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing."
        format.html { render :action => 'new' }
        format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    respond_to do |format|
      if @gallery.update_attributes(params[:gallery])
        flash[:notice] = "Your gallery has been saved below."
        format.html { redirect_to( params[:continue] ? edit_admin_gallery_url(@gallery) : admin_gallery_url(@gallery)) }
        format.xml  { head :ok }
      else
        flash[:error] = "Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing."
        form.html { render(:action => 'edit') }
        form.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @gallery.destroy
    flash[:notice] = "Gallery and its images were successfully removed from the site."
    
    respond_to do |format|
      format.html { redirect_to(admin_galleries_url) }
      format.xml  { head :ok }
    end
  end
  
  def clear_thumbs
    @gallery.clear_thumbs
    flash[:notice] = 'Thumbnails have been deleted correctly'
    
    respond_to do |format|
      format.html { redirect_to admin_gallery_url(@gallery) }
      format.xml  { head :ok }
    end
  end 
  
  def reorder    
    conditions = params.include?(:id) ? ["parent_id = ?", params[:id]] : "parent_id IS NULL"
    @galleries = Gallery.find(:all, :conditions => conditions, :order => 'position')
  end
  
  def update_order
    if request.post? && params.key?(:sort_order)
      list = params[:sort_order].split(',')
      list.size.times do |i|
        gallery = Gallery.find(list[i])
        gallery.position = i + 1
        gallery.save
      end
      redirect_to admin_galleries_url
    end    
  end
     
   
private  
  
  def find_gallery
    @gallery = Gallery.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_galleries_url
  end
  
  def galleries_absolute_path
    galleries_folder = Radiant::Config['gallery.path_prefix']
    galleries_path = File.expand_path(File.join(RAILS_ROOT, galleries_folder))    
  end    
  
end
