module GalleriesHelper
  
  def gallery_toolbar
    content = '<div class="toolbar">'
    links = []
    links << link_to('New file', new_admin_gallery_item_path(@gallery),     :onclick => "Gallery.openPopup('#{new_admin_gallery_item_path(@gallery)}',      'New file'); return false")
    links << link_to('Import files', new_admin_gallery_item_path(@gallery), :onclick => "Gallery.openPopup('#{new_admin_gallery_importing_path(@gallery)}', 'New file'); return false")
    links << link_to('Edit gallery', edit_admin_gallery_path(@gallery))
    links << link_to('Clear thumbs', clear_thumbs_admin_gallery_path(@gallery))
    links << link_to('Add Child Gallery', new_admin_gallery_child_path(@gallery))
    links << link_to('Destroy gallery', admin_gallery_path(@gallery), :method => 'delete', :confirm => 'Are you sure?')
    content << links.join(" | ")
    content << '</div>'
  end    

  def gallery_zoom_slider
    %|<div id="gallery_items_panel_zoom"> 
      <div class="wrapper">
        <div id="track">
          <div id="handle"></div>
        </div>
      </div>
    </div>|
  end
  
  def gallery_popup_tab_link_to(controller_name, text, url)
    content = link_to(text, url)
    content = "<strong>#{content}</strong>" if "#{controller_name}Controller" == controller.class.name
    content
  end
 
end