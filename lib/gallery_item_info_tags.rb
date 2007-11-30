module GalleryItemInfoTags
  
  include Radiant::Taggable

  class GalleryTagError < StandardError; end
  
  tag 'gallery:item:infos' do |tag|
    tag.expand
  end
  
  tag 'gallery:item:infos:each' do |tag|
    content = ""
    item = find_item(tag)    
    item.infos.each do |info|
      tag.locals.info = info
      content << tag.expand
    end
    content
  end
     
  tag 'gallery:item:info' do |tag|
    tag.locals.info = find_info(tag)
    tag.expand
  end
  
  tag 'gallery:item:info:name' do |tag|
    info = find_info(tag)
    info.name.humanize if info
  end
  
  tag 'gallery:item:info:value' do |tag|
    info = find_info(tag)
    format_gallery_item_info_value(info, tag) if info
  end    
  
private

  def find_info(tag)
    item = find_item(tag)
    return unless item
    if tag.locals.info
      tag.locals.info
    elsif name = tag.attr["name"]
      get_gallery_item_info_by_name(item, name)
    end
  end

  def get_gallery_item_info_by_name(item, info_name)
    item.infos.find(:first, :conditions => ["name = ?", info_name])    
  end
  
  def format_gallery_item_info_value(info, tag)
    name, value = info.name, info.value
    if (format = tag.attr["date_format"]) && value.is_a?(Time)
      value.strftime(format)
    else
      value
    end
  end 
    
end
