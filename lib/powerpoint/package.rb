require 'zip/filesystem'
require 'fileutils'
require 'tmpdir'

module Powerpoint
  class Powerpoint::Package

    attr_accessor :pptx_path, :extract_path,
      :slides, :slide_relationships,
      :slide_layouts, :slide_layout_relationships,
      :slide_masters, :slide_master_relationships,
      :notes_slides, :notes_slide_relationships,
      :notes_masters, :notes_master_relationships,
      :presentations, :presentation_relationships,
      :media, :content_types

    def initialize filename
      raise "Not a valid file format." unless (['.pptx'].include? File.extname(filename).downcase)
      raise "cannot access '#{filename}' as a package file" unless File.file?(filename)

      @content_types = nil
      @presentations = nil
      @presentation_relationships = nil
      @slides = []
      @slide_relationships = []
      @slide_layouts = []
      @slide_layout_relationships = []
      @slide_masters = []
      @slide_master_relationships = []
      @notes_slides = []
      @notes_slide_relationships = []
      @notes_masters = []
      @notes_master_relationships = []
      @media = []
      @extract_path =  File.join Dir.tmpdir, "extract_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}"
      Zip::File.open(filename) do |files|
        files.each do |f|
          fname = f.name
          f_path = File.join(@extract_path, fname)
          FileUtils.mkdir_p(File.dirname(f_path))
          files.extract(f, f_path) unless File.exist?(f_path)

          if fname.match /ppt\/slides\/(slide\d+)\.xml/
            @slides << Slide.new(fname, self)
          elsif fname.match /ppt\/slides\/_rels\/(slide\d+)\.xml\.rels/
            @slide_relationships << SlideRelationship.new(fname, self)
          elsif fname.match /ppt\/slideLayouts\/(slideLayout\d+)\.xml/
            @slide_layouts << SlideLayout.new(fname, self)
          elsif fname.match /ppt\/slideLayouts\/_rels\/(slideLayout\d+)\.xml\.rels/
            @slide_layout_relationships << SlideLayoutRelationship.new(fname, self)
          elsif fname.match /ppt\/slideMasters\/(slideMaster\d+)\.xml/
            @slide_masters << SlideMaster.new(fname, self)
          elsif fname.match /ppt\/slideMasters\/_rels\/(slideMaster\d+)\.xml\.rels/
            @slide_master_relationships << SlideMasterRelationship.new(fname, self)
          elsif fname.match /ppt\/notesSlides\/(notesSlide\d+)\.xml/
            @notes_slides << NotesSlide.new(fname, self)
          elsif fname.match /ppt\/notesSlides\/_rels\/(notesSlide\d+)\.xml\.rels/
            @notes_slide_relationships << NotesSlideRelationship.new(fname, self)
          elsif fname.match /ppt\/notesMasters\/(notesMaster\d+)\.xml/
            @notes_masters << NotesMaster.new(fname, self)
          elsif fname.match /ppt\/notesMasters\/_rels\/(notesMaster\d+)\.xml\.rels/
            @notes_master_relationships << NotesMasterRelationship.new(fname, self)
          elsif fname.match /ppt\/media\/\S+\.\S+/
            @media << Media.new(fname, self)
          elsif fname.match /ppt\/(presentation\.xml)/
            @presentations = Presentation.new(fname, self)
          elsif fname.match /ppt\/_rels\/(presentation\.xml\.rels)/
            @presentation_relationships = PresentationRelationship.new(fname, self)
          elsif fname.match /^\[Content_Types\]\.xml/
            @content_types = ContentType.new(fname, self)
          end
        end
      end
    end

    def combine_package(source_package)
      resource_types = ['media', 'slides', 'notes_slides']
      resource_types.each do |folder|
        source_package = dummy_add_resources(source_package, folder)
      end
      resource_types.each do |folder|
        add_resources(source_package, folder)
      end

      relationship_types = ['notes_slide_relationships', 'slide_relationships']
      relationship_types.each do |folder|
        source_package = dummy_add_resources(source_package, folder)
      end
      relationship_types.each do |folder|
        add_resources(source_package, folder)
      end

      dummy_combine_resource(source_package, source_package.presentation_relationships)
      combine_resource(source_package, source_package.presentation_relationships)

      combine_resource(source_package, source_package.presentations)

      combine_resource(source_package, source_package.content_types)
    end

    def dummy_combine_resource(source_package, source_resource)
      resource = self.try(source_resource.resource_folder_name)
      source_package = source_resource.dummy_combine_resource(source_package, resource)
    end

    def combine_resource(source_package, source_resource)
      resource = self.try(source_resource.resource_folder_name)
      resource.combine_resource(source_package, source_resource)
    end

    def add_resources(source_package, resource_folder)
      return if self == source_package
      resources = source_package.try(resource_folder)
      resources = [resources] unless resources.is_a? Array
      resources.sort{ |a, b| a.resource_number <=> b.resource_number } \
        .each { |r| add_resource(source_package, r) }
    end

    def add_resource(source_package, resource)
      return if self == source_package
      resources = self.try(resource.resource_folder_name)
      resources = [resources] unless resources.is_a? Array
      resource.dumplicate_to(self)
      resources << resource.class.new(resource.filename, self)
      self.send("#{resource.resource_folder_name}=", resources)
    end

    def dummy_add_resources(source_package, resource_folder)
      return if self == source_package
      resources = source_package.try(resource_folder)
      resources = [resources] unless resources.is_a? Array
      resources.sort{ |a, b| b.resource_number <=> a.resource_number } \
        .each { |r| source_package = dummy_add_resource(source_package, r) }
      source_package
    end

    def dummy_add_resource(source_package, resource)
      return if self == source_package
      new_resource_filename = compute_new_filename(resource)
      source_package = resource.rename(source_package, new_resource_filename)
      source_package
    end

    def compute_new_filename(resource)
      current_resources = self.try(resource.resource_folder_name)
      if current_resources.is_a? Array
        max_resource = current_resources.select{ |r| resource.same_group?(r) } \
          .sort{ |a, b| b.resource_number <=> a.resource_number }.first
        resource.generate_new_filename(max_resource)
      else
        current_resources.try(:filename)
      end
    end

    def save path
      @pptx_path = path
      File.delete(path) if File.exist?(path)
      Powerpoint.compress_pptx @extract_path, @pptx_path
      FileUtils.rm_rf(@extract_path)
      path
    end
  end
end
