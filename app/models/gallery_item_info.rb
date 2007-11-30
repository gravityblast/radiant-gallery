class GalleryItemInfo < ActiveRecord::Base
  
  belongs_to :item, :class_name => "GalleryItem", :foreign_key => 'gallery_item_id'  
  
  def value=(object)
    if object.is_a?(Rational)
      self.value_string = object.to_s
    elsif object.is_a?(Numeric)
      self.value_integer = object
    elsif object.is_a?(Time)
      self.value_datetime = object
    else
      text = object.to_s
      column = text.size > 255 ? 'text' : 'string'
      self.send("value_#{column}=", text)
    end
  end
  
  def value
    %w[string datetime integer text].each do |type|
      return_value = self.send("value_#{type}")
      return return_value if return_value
    end
  end
    
end
