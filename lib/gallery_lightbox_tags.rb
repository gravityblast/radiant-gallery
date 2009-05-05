module GalleryLightboxTags
  #tags available globally, not just on GalleryPages
  include Radiant::Taggable  
  
  desc %{
    Usage:
    <pre><code><r:gallery:lightbox_stuff /></code></pre>
    Provides lightbox stylesheet links to be included in HTML HEAD section }
  tag 'gallery:lightbox_stuff' do |tag|
     %{
<link href="/stylesheets/extensions/gallery/lightbox.css" rel="stylesheet" type="text/css" />
<script src="/javascripts/extensions/gallery/prototype.js" type="text/javascript"></script>
<script src="/javascripts/extensions/gallery/scriptaculous.js?load=builder,effects" type="text/javascript"></script>
<script src="/javascripts/extensions/gallery/lightbox.js" type="text/javascript"></script>
    }
  end
  
  desc %{
    Usage:
    <pre><code><r:gallery:lightbox [thumb_width='width' thumb_height='height'] [thumb_size='size' thumb_geometry='c84x84'] 
    [image_width='width' image_height='height'] [image_size='size'] [thumbnail='none'] [class='klass' limit='5']/></code></pre>
    Provides a sized image for current gallery item.
    Current size values are: icon, small, medium, large, original }
  tag 'gallery:lightbox' do |tag|    
    tag.attr["thumb_size"] = :small unless (tag.attr["thumb_width"] || tag.attr["thumb_height"] || tag.attr["thumb_size"])
    tag.attr["image_size"] = :large unless (tag.attr["image_width"] || tag.attr["image_height"] || tag.attr["image_size"])
    gallery = find_gallery(tag)
    
    klass = " class='#{tag.attr['class']}'" if tag.attr['class']
    content = %{ <div class="lightbox_gallery_list"><ul> }      
    limit = tag.attr['limit'].to_i > 0 ? tag.attr['limit'].to_i - 1 : gallery.items.length - 1
    gallery.items[0..limit].each do |item| 
      width, height, size, geometry = tag.attr["thumb_width"], tag.attr["thumb_height"], tag.attr["thumb_size"], tag.attr["thumb_geometry"]
      thumb_path = item.thumb(:width => width, :height => height, :geometry => geometry).public_filename
      width, height, size, geometry = tag.attr["image_width"], tag.attr["image_height"], tag.attr["image_size"], tag.attr["image_geometry"] 
      image_path = item.thumb(:width => width, :height => height, :geometry => geometry).public_filename 
      li_start_tag = tag.attr["thumbnail"] == 'none' ? "<li#{klass}>" : %{<li style="background-image: url('#{thumb_path}')"#{klass}>}       
      content << %{ #{li_start_tag}     
                    <a href="#{image_path}" rel="lightbox[#{gallery.name.downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/,'')}]" title="#{item.name}">
                    #{item.name}    
                    </a></li>}
    end unless gallery.items.empty?
    content << %{ </ul></div><div class="lightbox_gallery_list_clearer"></div> }
  end
    
end
