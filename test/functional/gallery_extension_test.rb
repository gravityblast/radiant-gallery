require File.dirname(__FILE__) + '/../test_helper'

class GalleryExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal RADIANT_ROOT + '/vendor/extensions/gallery', GalleryExtension.root
    assert_equal 'Gallery', GalleryExtension.extension_name
  end
  
end
