class GalleryPage < Page 
  
  include GalleryPageExtensions
  
  def cache?
    false
  end
  
end

