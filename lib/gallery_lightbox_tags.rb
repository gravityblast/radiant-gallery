module GalleryLightboxTags
  #tags available globally, not just on GalleryPages
  include Radiant::Taggable  
  
  desc %{
    Usage:
    <pre><code><r:gallery:item:description /></code></pre>
    Provides lightbox stylesheet links to be included in HTML HEAD section }
  tag 'gallery:lightbox_stuff' do |tag|
     %{
<link href="/stylesheets/lightbox/lightbox.css" rel="stylesheet" type="text/css" />
<script src="/javascripts/prototype.js" type="text/javascript"></script>
<script src="/javascripts/lightbox.js" type="text/javascript"></script>
<script src="/javascripts/effects.js?1174869275" type="text/javascript"></script>
    }
  end
  
  desc %{
    Usage:
    <pre><code><r:gallery:lightbox [thumb_width='width' thumb_height='height'] [thumb_size='size'] [image_width='width' image_height='height'] [image_size='size'] /></code></pre>
    Provides a sized image for current gallery item.
    Current size values are: icon, small, medium, large, original }
  tag 'gallery:lightbox' do |tag|    
    tag.attr["thumb_size"] = :small unless (tag.attr["thumb_width"] || tag.attr["thumb_height"] || tag.attr["thumb_size"])
    tag.attr["image_size"] = :large unless (tag.attr["image_width"] || tag.attr["image_height"] || tag.attr["image_size"])
    gallery = find_gallery(tag)
    
    content = %{ <div class="lightbox_gallery_list"><ul> }
    gallery.items.each do |item| 
      width, height, size = tag.attr["thumb_width"], tag.attr["thumb_height"], tag.attr["thumb_size"]
      thumb_path = item.thumb(:width => width, :height => height).public_filename
      width, height, size = tag.attr["image_width"], tag.attr["image_height"], tag.attr["image_size"]
      image_path = item.thumb(:width => width, :height => height).public_filename
      content << %{      
<li style="background-image: url('#{thumb_path}')">
  <a href="#{image_path}" rel="lightbox[#{gallery.name}]" title="#{item.name}">
    #{item.name}    
  </a>
</li>}
    end unless gallery.items.empty?
    content << %{ </ul></div><div class="lightbox_gallery_list_clearer"></div> }
  end
    
end
