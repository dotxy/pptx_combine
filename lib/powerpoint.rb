require 'powerpoint/constants'
require 'powerpoint/package_resource'
require 'powerpoint/relationship'
require 'powerpoint/package'
require 'powerpoint/content_type'
require 'powerpoint/media'
require 'powerpoint/notes_master_relationship'
require 'powerpoint/notes_master'
require 'powerpoint/notes_slide_relationship'
require 'powerpoint/notes_slide'
require 'powerpoint/presentation'
require 'powerpoint/presentation_relationship'
require 'powerpoint/slide_layout_relationship'
require 'powerpoint/slide_layout'
require 'powerpoint/slide_master_relationship'
require 'powerpoint/slide_master'
require 'powerpoint/slide_relationship'
require 'powerpoint/slide'

module Powerpoint

  def self.decompress_pptx in_path, out_path
  	Zip::File.open(in_path) do |zip_file|
  	  zip_file.each do |f|
  	    f_path = File.join(out_path, f.name)
  	    FileUtils.mkdir_p(File.dirname(f_path))
  	    zip_file.extract(f, f_path) unless File.exist?(f_path)
  	  end
  	end
  end

  def self.compress_pptx in_path, out_path
    Zip::File.open(out_path, Zip::File::CREATE) do |zip_file|
      Dir.glob("#{in_path}/**/*", ::File::FNM_DOTMATCH).each do |path|
        zip_path = path.gsub("#{in_path}/","")
        next if zip_path.match(/\.+$/) || zip_path.match(/DS_Store$/)
        begin
          zip_file.add(zip_path, path)
        rescue Zip::ZipEntryExistsError
          raise "#{out_path} allready exists!"
        end
      end
    end
  end
end
