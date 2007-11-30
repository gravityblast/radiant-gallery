require 'tempfile'

namespace :radiant do
  namespace :extensions do
    namespace :gallery do
      
      desc "Runs the migration of the Gallery extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          GalleryExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          GalleryExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Gallery to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[GalleryExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(GalleryExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end
      
      desc ""
      task :import_layouts => :environment do
        layouts_path = File.join(GalleryExtension.root, 'layouts')
        extension = ".radius"
        layouts = Dir[File.join(layouts_path, "*#{extension}")].collect do |path|
          filename = File.basename(path)
          {
            :path => path,
            :name => filename[0...(filename.size - extension.size)].humanize
          }
        end
        puts "Select which layout to create (leave blank to skip):"
        layouts.each_with_index do |layout, index|
          puts "#{index + 1}. #{layout[:name]}"
        end
        print "[1-#{layouts.size}] values separated by commas: "
        answer = STDIN.gets.chomp
        layouts_to_install = answer.split(',').collect{|number| number.strip.to_i}
        layouts_to_install.each do |number|
          if (1..layouts.size).include?(number)
            layout = layouts[number-1]
            print "Importing layout '#{layout[:name]}'..."
            File.open(layout[:path], 'r') do |file|
              original_name = "Gallery layout - #{layout[:name]}"
              name, i = original_name, 1
              while Layout.find_by_name(name) do
                name = "#{original_name} (#{i += 1})"
              end
             #TODO: add created by 
              Layout.create(:name => name, :content => file.read, :content_type => "text/html" )           
              puts 'OK'
            end
          else
            puts "Error: #{number} is not a valid layout."
          end
        end
      end
      
      desc "Migrates and copies files in public/admin"
      task :install => [:environment, :migrate, :update, :import_layouts] do
        puts "Gallery extension has been installed."
        puts "1. Create a new page with 'Gallery' as page type."
        puts "2. Select a gallery layout for your page."
        puts "3. Start creating your galleries."
      end
      
      desc "Report Gallery statistics"
      task :stats => :environment do
        require 'gallery_statistics.rb'
        GalleryStatistics.new.to_s
      end
            
    end
  end
end unless __FILE__.include? '_darcs'
