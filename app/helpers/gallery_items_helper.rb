module GalleryItemsHelper
  
  def item_label(item)
    content = "<div id=\"item_#{item.id}_name\" class=\"label\" title=\"Edit item info\">"
    content << link_to(item.name, formatted_edit_admin_gallery_item_path(@gallery, item, :html), :class => 'lightwindow', :params => 'lightwindow_width=800,lightwindow_height=350')
    content << '</div>'
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
      content << link_to(image_tag('extensions/gallery/admin/show.png'), item.thumb(:width => 500, :height => 500, :prefix => :admin_preview).public_filename, :class => 'lightwindow', :rel => "Gallery [#{item.gallery.name}]", :title => item.name)
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
        :class => "delete_button",
        :title => 'Destroy',
        :method => 'delete',        
        :onclick => "GalleryItems.delete_if_confirm(#{item.id}, '#{admin_gallery_item_url(@gallery, item)}'); return false;"
  end
  
  def item_edit_button(item)
    link_to(image_tag('extensions/gallery/admin/edit.png'), formatted_edit_admin_gallery_item_path(@gallery, item, :html), :class => 'lightwindow', :params => 'lightwindow_width=800,lightwindow_height=350')
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