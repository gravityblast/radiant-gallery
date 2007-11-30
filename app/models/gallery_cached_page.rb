class GalleryCachedPage < Page 
  
  include GalleryPageExtensions
  
  def cache?
    true
  end
  
end

