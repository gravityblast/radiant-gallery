module PageExtensionsForGallery
  class << self
    def included(base)
      base.belongs_to :base_gallery, :class_name => 'Gallery', :foreign_key => 'base_gallery_id'
    end
  end
end