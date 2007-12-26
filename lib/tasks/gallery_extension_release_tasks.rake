require File.dirname(__FILE__) + '/../radiant_gallery'

namespace :radiant do
  namespace :extensions do
    namespace :gallery do
      
      GALLERY_PKG_NAME = 'radiant-gallery'
      GALLERY_PKG_VERSION = RadiantGallery::Version.to_s
      GALLERY_PKG_FILE_NAME = "#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}"
      GALLERY_PKG_DESTINATION = ENV["GALLERY_PKG_DESTINATION"] || File.expand_path(RADIANT_ROOT + "/../radiant-gallery-pkg/#{GALLERY_PKG_VERSION}")
      
      task :clean do
        rm_rf GALLERY_PKG_DESTINATION
      end
      
      desc "Packages the radiant gallery extension"
      task :package => [ :clean ] do
        puts GALLERY_PKG_DESTINATION
        mkdir_p GALLERY_PKG_DESTINATION
        system %{cd vendor/extensions; tar -czvf #{GALLERY_PKG_DESTINATION}/#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}.tgz gallery}
        system %{cd vendor/extensions; zip -r    #{GALLERY_PKG_DESTINATION}/#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}.zip gallery}        
      end
    end
  end
end