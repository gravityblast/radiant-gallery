require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
GalleryItemController.class_eval { def rescue_action(e) raise e end }

class GalleryItemControllerTest < Test::Unit::TestCase
  def setup
    @controller = GalleryItemController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
