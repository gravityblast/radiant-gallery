class GalleryStatistics

  def to_s
    print_header
    loop_galleries
    print_splitter
    print_total
    print_splitter    
  end
  
  def print_total
    galleries_count = "#{Gallery.count} galleries"
    images_count = GalleryItem.count("parent_id IS NULL AND content_type LIKE '%image%'")
    thumbnails_count = GalleryItem.count("parent_id IS NOT NULL")    
    output = "| "
    output << "Total:".ljust(55 - galleries_count.size)
    output << galleries_count.to_s.ljust(galleries_count.size)
    output << " | "
    output << Gallery.count("parent_id IS NOT NULL").to_s.rjust(8)
    output << " | "
    output << GalleryItem.count("parent_id IS NULL").to_s.rjust(5)
    output << " | "
    output << images_count.to_s.rjust(6)
    output << " | "
    output << "#{thumbnails_count}".rjust(10)
    output << " | "
    output << GalleryItem.count("parent_id IS NULL AND content_type NOT LIKE '%image%'").to_s.rjust(5)
    output << " |"
    puts output
  end
  
  def loop_galleries
    Gallery.find(:all).each do |g|
      name = g.name.length > 45 ? "#{g.name[0...45]}..." : g.name
      output = "| "
      output << g.id.to_s.rjust(4)
      output << " | "
      output << name.ljust(48)
      output << " | "
      output << g.children.size.to_s.rjust(8)
      output << " | "
      output << g.items.size.to_s.rjust(5)
      output << " | "
      output << g.images.size.to_s.rjust(6)
      output << " | "
      output << g.thumbnails.size.to_s.rjust(10)
      output << " | "
      output << g.files.size.to_s.rjust(5)
      output << " |"
      puts output      
    end    
  end
  
  def print_header
    print_splitter
    puts "|   ID | Name                                             | Children | Items | Images | Thumbnails | Files |"
    print_splitter
  end
  
  def print_splitter
    puts "+------+--------------------------------------------------+----------+-------+--------+------------+-------+"
  end
  
end