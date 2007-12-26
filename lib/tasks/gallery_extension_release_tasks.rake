require File.dirname(__FILE__) + '/../radiant_gallery'

namespace :radiant do
  namespace :extensions do
    namespace :gallery do
      
      GALLERY_PKG_NAME = 'radiant-gallery'
      GALLERY_PKG_VERSION = RadiantGallery::Version.to_s
      GALLERY_PKG_FILE_NAME = "#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}"
      GALLERY_PKG_DESTINATION = ENV["GALLERY_PKG_DESTINATION"] || File.expand_path(RADIANT_ROOT + "/../radiant-gallery-pkg/#{GALLERY_PKG_VERSION}")
      
      GALLERY_RUBY_FORGE_PROJECT = GALLERY_PKG_NAME
      GALLERY_RUBY_FORGE_USER = ENV['RUBY_FORGE_USER'] || 'pilu'

      GALLERY_RELEASE_NAME  = GALLERY_PKG_VERSION
      GALLERY_RUBY_FORGE_GROUPID = '5132'
      GALLERY_RUBY_FORGE_PACKAGEID = '6446'
      
      task :clean do
        rm_rf GALLERY_PKG_DESTINATION
      end
      
      desc "Packages the radiant gallery extension"
      task :package => [ :clean ] do
        mkdir_p GALLERY_PKG_DESTINATION
        system %{cd vendor/extensions; tar -czvf #{GALLERY_PKG_DESTINATION}/#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}.tgz gallery}
        system %{cd vendor/extensions; zip -r    #{GALLERY_PKG_DESTINATION}/#{GALLERY_PKG_NAME}-#{GALLERY_PKG_VERSION}.zip gallery}
      end
      
      desc "Publishes the release files to RubyForge."
      task :release => [ :clean, :package ] do
        system %{rubyforge login --username #{GALLERY_RUBY_FORGE_USER}}
        %w[ tgz zip ].each do |extension|
          file = File.join(GALLERY_PKG_DESTINATION, "#{GALLERY_PKG_FILE_NAME}.#{extension}")
          system %{rubyforge add_release #{GALLERY_RUBY_FORGE_GROUPID} #{GALLERY_RUBY_FORGE_PACKAGEID} "#{GALLERY_RELEASE_NAME}" #{file}}
        end
      end
      
      
    end

  end
end