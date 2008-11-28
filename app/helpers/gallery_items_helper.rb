module GalleryItemsHelper
  
  def item_label(item)
    content = "<div class=\"label\" title=\"Edit item info\">"
    content << link_to(item_label_text(item), admin_gallery_item_path(@gallery, item), :class => 'action edit')
    content << '</div>'
  end
  
  def item_label_text(item)
    item.name.blank? ? '&nbsp;' : item.name
  end
  
  def item_buttons(item)
    content = '<div class="buttons">'
    content << item_show_button(item)
    content << item_edit_button(item)
    content << item_edit_image_button(item)
    content << item_destroy_button(item)
    content << '</div>'
  end

  def item_show_button(item)
    content = ''
    if item.image?
      content << link_to(image_tag('extensions/gallery/admin/show.png'), item.thumb(:width => 500, :height => 500, :prefix => :admin_preview).public_filename, :rel => 'lightbox[#{item.gallery.name}]', :title => item.name)
    else
      content << link_to(image_tag('extensions/gallery/admin/show.png'), item.public_filename, :title => item.name)
    end
  end
  
  
  def item_edit_image_button(item)
    content = ''
    #if item.image?
    #  content << link_to(image('gallery/edit-image.png'),  gallery_item_edit_image_url(:id => item), :title => 'Edit image' )
    #end
    content
  end
  
  def item_destroy_button(item)
    link_to image_tag('extensions/gallery/admin/destroy.png'), admin_gallery_item_url(@gallery, item),
      :class => 'action destroy', :title => 'Destroy'
  end
  
  def item_edit_button(item)
    link_to image_tag('extensions/gallery/admin/edit.png'), admin_gallery_item_path(@gallery, item),
      :class => 'action edit', :title => 'Edit'
  end
  
  def item_preview(item)
    content = "<div class=\"image\">"
    if item.image?
      thumb = item.thumb(:width => 300, :height => 300, :prefix => :admin_thumb)
      width_perc, height_perc = proportional_resize(thumb.width, thumb.height, 100, 100)    
      margin_top = (100 - height_perc) / 2
      content << "<img style=\"margin-top: #{margin_top}%\" src=\"#{thumb.public_filename}\" width=\"#{width_perc}%\" height=\"#{height_perc}%\" />"
    else
      width_perc, height_perc = proportional_resize(100, 100, 100, 100)
      margin_top = (100 - height_perc) / 2
      content << "<img style=\"margin-top: #{margin_top}%\" src=\"/images/admin/extensions/gallery/file.png\" width=\"#{width_perc}%\" height=\"#{height_perc}%\" />"
    end
    content << "</div>"
  end    
  
private

  def proportional_resize(width, height, max_width, max_height)   
    aspectratio = max_width.to_f / max_height.to_f
    picratio = width.to_f / height.to_f
    scaleratio = picratio > aspectratio ? max_width.to_f / width : max_height.to_f / height   
    [width * scaleratio, height * scaleratio]
  end    
end