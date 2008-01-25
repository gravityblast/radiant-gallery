module GalleryTags
  #tags available globally, not just on GalleryPages
  include Radiant::Taggable
  
  class GalleryTagError < StandardError; end
  
  desc %{    
    Usage:
    <pre><code><r:gallery [id='id'] [name='name']>...</r:gallery></code></pre>
    Selects current gallery }
  tag "gallery" do |tag|
    tag.locals.gallery = find_gallery(tag)
    tag.expand
  end
  
  tag 'gallery:if_current' do |tag|    
    tag.expand if @current_gallery
  end
  
  tag 'gallery:unless_current' do |tag|    
    tag.expand unless @current_gallery
  end
  
  tag 'gallery:current' do |tag|    
    tag.locals.item = @current_gallery
    tag.expand
  end  
  
  desc %{    
    Usage:
    <pre><code><r:gallery:name /></code></pre>
    Provides name for current gallery }
  tag "gallery:name" do |tag|
    gallery = tag.locals.gallery    
    gallery.name
  end
  
  tag 'gallery:breadcrumbs' do |tag|
    gallery = find_gallery(tag)
    breadcrumbs = []
    gallery.ancestors_from(self.base_gallery_id).unshift(gallery).each do |ancestor|
      if @current_gallery == ancestor && @current_item.nil?
        breadcrumbs << %|#{ancestor.name}|
      else
        ancestor_absolute_url = File.join(tag.render('url'), ancestor.url(self.base_gallery_id))
        breadcrumbs.unshift(%|<a href="#{ancestor_absolute_url}">#{ancestor.name}</a>|)
      end
    end
    separator = tag.attr['separator'] || ' &gt; '
    breadcrumbs.join(separator)
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:description /></code></pre>
    Provides description for current gallery }
  tag "gallery:description" do |tag|
    gallery = tag.locals.gallery
    gallery.description
  end  
  
  desc %{    
    Usage:
    <pre><code><r:gallery:children:each>...</r:gallery:children:each></code></pre>
    Iterates over all children in current gallery }
  tag "gallery:children:each" do |tag|
    content = ""
    gallery = find_gallery(tag)
    options = {}
    options[:conditions] = {:hidden => false, :external => false}
    by = tag.attr['by'] ? tag.attr['by'] : "id"
    unless Gallery.columns.find{|c| c.name == by }
      raise GalleryTagError.new("`by' attribute of `each' tag must be set to a valid field name")
    end
    options[:limit] = tag.attr['limit'] ? tag.attr['limit'].to_i : 9999
    options[:offset] = tag.attr['offset'] ? tag.attr['offset'].to_i  : 0
    order = (%w[ASC DESC].include?(tag.attr['order'].to_s.upcase)) ? tag.attr['order'] : "ASC"
    options[:order] = "#{by} #{order}"        
    gallery.children.find(:all, options).each do |sub_gallery| 
      tag.locals.gallery = sub_gallery
      content << tag.expand      
    end
    content
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:if_children>...</r:gallery:if_children></code></pre> }
  tag "gallery:if_children" do |tag|
    gallery = find_gallery(tag)  
    tag.expand unless gallery.children.empty?
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:unless_children>...</r:gallery:unless_children></code></pre> }
  tag "gallery:unless_children" do |tag|
    gallery = find_gallery(tag)  
    tag.expand if gallery.children.empty?
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:if_galleries>...</r:gallery:if_galleries></code></pre> }
  tag "gallery:if_galleries" do |tag|
    gallery = find_gallery(tag)
    if gallery && !gallery.children.empty?
      tag.expand
    elsif gallery && gallery.children.empty?
      nil
    elsif Gallery.count(:conditions => {:parent_id => nil, :hidden => false})
      tag.expand
    end
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:unless_galleries>...</r:gallery:unless_galleries></code></pre> }
  tag "gallery:unless_galleries" do |tag|
    gallery = find_gallery(tag)
    if gallery && gallery.children.empty?
      tag.expand
    elsif gallery && !gallery.children.empty?
      nil
    elsif Gallery.count(:conditions => {:parent_id => nil, :hidden => false})
      nil
    end
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:if_items>...</r:gallery:if_items></code></pre> }
  tag "gallery:if_items" do |tag|
    gallery = find_gallery(tag)    
    tag.expand if gallery && !gallery.items.empty?
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:unless_items>...</r:gallery:unless_items></code></pre> }
  tag "gallery:unless_items" do |tag|
    gallery = find_gallery(tag)  
    tag.expand if !gallery || gallery.items.empty?
  end
  
  desc %{
    Usage:
    <pre><code><r:gallery:item:children_size /></code></pre>
    Provides the number of children for current gallery }
  tag "gallery:gallery:children_size" do |tag|  
    gallery = find_gallery(tag)
    gallery.children.size    
  end
  
  desc %{
    Usage:
    <pre><code><r:gallery:item:items_size /></code></pre>
    Provides the number of items for current gallery }
  tag "gallery:gallery:items_size" do |tag|  
    gallery = find_gallery(tag)
    gallery.items.size    
  end
  

protected
  
  def find_gallery(tag)
    if tag.locals.gallery
      tag.locals.gallery
    elsif tag.attr["id"]
      Gallery.find_by_id tag.attr["id"]
    elsif @current_gallery
      @current_gallery
    end
  end    
  
end
