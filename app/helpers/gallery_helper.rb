module GalleryHelper
  
  def gallery_toolbar
    content = '<div class="toolbar">'
    links = []
    links << link_to('Edit gallery', gallery_edit_url(:id => @gallery.id))
    links << link_to('Import files', gallery_import_url(:id => @gallery.id))
    links << link_to('Clear thumbs', gallery_clear_thumbs_url(:id => @gallery))
    links << link_to('Add Child Gallery', gallery_new_child_url(:parent_id => @gallery))
    links << link_to('Delete gallery', gallery_remove_url(:id => @gallery))
    content << links.join(" | ")
    content << '</div>'
  end
  
  def item_label(item)
    "<div id=\"item_#{item.id}_name\" class=\"label\" onclick=\"GalleryItemPopup.open(#{item.id}); return false;\" title=\"Edit item info\">#{item.name}</div>"
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
      content << link_to(image('gallery/show.png'), item.thumb(:width => 500, :height => 500, :prefix => :admin).public_filename, :rel => "lightbox[#{@gallery.name}]", :title => 'Show', :id => "item_#{item.id}_view_title" )
    else
      content << link_to(image('gallery/show.png'), item.public_filename, :title => item.name)
    end
  end
  
  
  def item_edit_image_button(item)
    content = ''
    if item.image?
      content << link_to(image('gallery/edit-image.png'),  gallery_item_edit_image_url(:id => item), :title => 'Edit image' )
    end
    content
  end
  
  def item_destroy_button(item)
    link_to(image('gallery/destroy.png', :id => "item_delete_#{item.id}"),
      gallery_item_destroy_url(:id => item.id), {
        :title => 'Destroy',
        :onclick => "GalleryItems.delete_if_confirm(#{item.id}, '#{gallery_item_destroy_url(:id => item.id)}'); return false;"
      }
    )
  end
  
  def item_edit_button(item)
    content = ''
    content << link_to(image('gallery/edit.png'), '#', :title => 'Edit', :onclick => "GalleryItemPopup.open(#{item.id}); return false;")
  end
  
  def item_preview(item)
    content = "<div class=\"image\">"
    if item.image?
      thumb = item.thumb(:width => 300, :height => 300, :prefix => :admin)
      width_perc, height_perc = proportional_resize(thumb.width, thumb.height, 100, 100)    
      margin_top = (100 - height_perc) / 2
      content << "<img style=\"margin-top: #{margin_top}%\" src=\"#{thumb.public_filename}\" width=\"#{width_perc}%\" height=\"#{height_perc}%\" />"
    end
    content << "</div>"
  end

  def gallery_zoom_slider
    %|<div id="slider"> 
      <div class="wrapper">
        <div id="track">
          <div id="handle"></div>
        </div>
      </div>
    </div>|
  end

private

 def proportional_resize(width, height, max_width, max_height)   
   aspectratio = max_width.to_f / max_height.to_f
   picratio = width.to_f / height.to_f
   scaleratio = picratio > aspectratio ? max_width.to_f / width : max_height.to_f / height   
   [width * scaleratio, height * scaleratio]
 end
 
end