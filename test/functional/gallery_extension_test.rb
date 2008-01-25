require File.dirname(__FILE__) + '/../test_helper'

class GalleryExtensionTest < Test::Unit::TestCase
    
  def test_initialization
    assert_equal File.expand_path(RAILS_ROOT) + '/vendor/extensions/gallery', GalleryExtension.root
    assert_equal 'Gallery', GalleryExtension.extension_name
  end
  
end
