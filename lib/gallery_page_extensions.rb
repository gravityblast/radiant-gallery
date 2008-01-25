module GalleryPageExtensions
  
  include Radiant::Taggable
  
  class << self
    def included(base)
      base.belongs_to :base_gallery, :class_name => 'Gallery', :foreign_key => 'base_gallery_id'
    end
  end
  
  
  
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
  
  tag "galleries" do |tag| 
    tag.expand
  end
  
  desc %{    
    Usage:
    <pre><code><r:galleries:each>...</r:galleries:each></code></pre>
    Iterates through all galleries }
  tag "galleries:each" do |tag|
    content = ''
    options = {}
    options[:conditions] = {:hidden => false, :external => false}
    
    level = tag.attr['level'] ? tag.attr['level'] : 'all'
    raise GalleryTagError.new('Invalid value for attribute level. Valid values are: current, top, bottom') unless %[current top bottom all].include?(level)
    case level
    when 'current'
      options[:conditions][:parent_id] = if @current_gallery
        @current_gallery.id
      elsif self.base_gallery
        self.base_gallery
      else
        nil
      end
    when 'top'
      options[:conditions][:parent_id] = nil
    when 'bottom'
      options[:conditions][:children_count] = 0
    end

    by = tag.attr['by'] ? tag.attr['by'] : "id"
    unless Gallery.columns.find{|c| c.name == by }
      raise GalleryTagError.new("`by' attribute of `each' tag must be set to a valid field name")
    end
    options[:limit] = tag.attr['limit'] ? tag.attr['limit'].to_i : 9999
    options[:offset] = tag.attr['offset'] ? tag.attr['offset'].to_i  : 0
    order = (%w[ASC DESC].include?(tag.attr['order'].to_s.upcase)) ? tag.attr['order'] : "ASC"
    options[:order] = "#{by} #{order}"
    galleries = Gallery.find(:all, options)
    galleries.each do |gallery|
      tag.locals.gallery = gallery
      content << tag.expand
    end
    content
  end
  
  desc %{    
    Usage:
    <pre><code><r:gallery:link /></code></pre>
    Provides link for current gallery }
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
  
  def current_gallery
    @current_gallery.inspect
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