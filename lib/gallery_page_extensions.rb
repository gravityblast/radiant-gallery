module GalleryPageExtensions
  
  include Radiant::Taggable        
  
  class GalleryTagError < StandardError; end   
  
  desc %{    
    Usage:
    <pre><code><r:gallery:if_index>...</r:gallery:if_index></code></pre> }
  tag "gallery:if_index" do |tag|
    unless @current_gallery
      tag.expand
    end
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:unless_index>...</r:gallery:unless_index></code></pre> }
  tag "gallery:unless_index" do |tag|
    if @current_gallery
      tag.expand
    end
  end        
  
  desc %{    
    Usage:
    <pre><code><r:gallery:link /></code></pre>
    Provides link for current gallery options are rendered 
    inline as key:value pairs i.e. class='value' id='value', etc.}
  tag "gallery:link" do |tag|
    gallery = find_gallery(tag)
    options = tag.attr.dup
    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('name')
    gallery_url = File.join(tag.render('url'), gallery.url(self.base_gallery_id))
    %{<a href="#{gallery_url}#{anchor}"#{attributes}>#{text}</a>}
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:gallery_url /></code></pre>
    Provides url for current gallery }
  tag "gallery:gallery_url" do |tag|
    gallery = find_gallery(tag)
    File.join(tag.render('url'), gallery.url(self.base_gallery_id))
  end    
  
  desc %{
    Usage:
    <pre><code><r:gallery:if_current_keywords>....</r:gallery:if_current_keywords></code></pre>
    Check to see if keywords are available in the parameters of the request URI
  }
  tag 'gallery:if_current_keywords' do |tag|    
    tag.expand if tag.globals.page.request.parameters['keywords']
  end  
  
  desc %{
    Usage:
    <pre><code><r:gallery:unless_current_keywords>....</r:gallery:unless_current_keywords></code></pre>
    Check to for no keywords being available in the parameters of the request URI
  }
  tag 'gallery:unless_current_keywords' do |tag|    
    tag.expand unless tag.globals.page.request.parameters['keywords']
  end
  
  desc %{
    Usage:
    <pre><code><r:gallery:current_keywords [separator=',']/></code></pre>
    Outputs the current keywords in the parameters of the request URI
  }
  tag "gallery:current_keywords" do |tag|          
    joiner = tag.attr['separator'] ? tag.attr['separator'] : ','
    tag.globals.page.request.parameters['keywords'].gsub(/\,/, joiner)
  end
  
  def current_gallery
    @current_gallery
  end
  
  def find_by_url(url, live = true, clean = false)
    url = clean_url(url)
    if url =~ /^#{self.url}(.*)/
      path, item, action = $1, nil, nil
      if path =~ /^(.*)\/(\d+\.\w+)\/(show|download)\/?$/
        path, item, action = $1, $2, $3
      end                                
      @current_gallery = find_gallery_by_path(path)      
      if @current_gallery
        if !item.nil? && !action.nil?
          item_id, item_extension = item.split(".")
          if @current_item = @current_gallery.items.find_by_id_and_extension(item_id, item_extension)
            self
          else
            super
          end
        else
          self  
        end        
      else
        super
      end
    else
      super
    end      
  end
  
  def find_gallery_by_path(slug)
    slugs = slug.split('/')
    current_gallery = nil    
    while slug = slugs.shift do
      unless current_gallery        
        current_gallery = Gallery.find_by_slug(slug, :conditions => {:parent_id => self.base_gallery_id || nil}) 
      else
        current_gallery = current_gallery.children.find_by_slug(slug)
      end
      break unless current_gallery
    end    
    current_gallery
  end 
  
end