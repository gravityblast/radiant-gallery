require 'tempfile'

namespace :radiant do
  namespace :extensions do
    namespace :gallery do
      namespace :version_0_7_0 do

        task :upgrade_filesystem_structure => :environment do
          print "Creating new filesystem structure..."
          GalleryItem.find(:all).each do |item|            
            old_folder_path = File.expand_path(File.join(RAILS_ROOT, 'public', 'galleries', item.gallery.id.to_s))
            old_thumbs_folder_path = File.join(old_folder_path, 'thumbs')
            new_folder_path = File.expand_path(File.dirname(item.full_filename))
            
            old_file_path   = File.join(old_folder_path, item.filename)
            new_file_path   = File.join(new_folder_path, item.filename)
            
            FileUtils.mkdir_p(new_folder_path)
            if File.exists?(old_file_path)
              FileUtils.cp(old_file_path, new_file_path)
              FileUtils.rm(old_file_path)
            end
            FileUtils.rm_rf(old_thumbs_folder_path)
          end
          puts "OK"
        end

      end                        
    end
  end
end
