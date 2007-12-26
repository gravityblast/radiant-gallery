require File.dirname(__FILE__) + '/../radiant_gallery'

namespace :radiant do
  namespace :extensions do
    namespace :gallery do
      
      GALLERY_PKG_NAME = 'radiant-gallery'
      GALLERY_PKG_VERSION = RadiantGallery::Version.to_s
      GALLERY_PKG_FILE_NAME = "#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}"
      GALLERY_PKG_DESTINATION = ENV["GALLERY_PKG_DESTINATION"] || "../radiant-gallery-pkg/#{GALLERY_PKG_VERSION}"
      
      task :clean do
        rm_rf GALLERY_PKG_DESTINATION
      end
      
      desc "Packages the radiant gallery extension"
      task :package => [ :clean ] do
        mkdir_p GALLERY_PKG_DESTINATION
        system %{tar -czvf #{GALLERY_PKG_DESTINATION}/#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}.tgz vendor/extensions/gallery}
        system %{zip -r    #{GALLERY_PKG_DESTINATION}/#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}.zip vendor/extensions/gallery}        
      end
    end
  end
end