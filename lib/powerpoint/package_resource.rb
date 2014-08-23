require 'fileutils'
require 'nokogiri'

module Powerpoint
  class PackageResource
    attr_accessor :filename
    attr_reader   :package, :extract_path

    def initialize filename, package
      @filename = filename
      @package = package
      @extract_path = @package.extract_path
    end

    def self.resource_folder_name
      relative_class_name = name.split("::")
      relative_class_name.shift
      relative_class_name.map(&:tableize).join("__")
    end

    def self.generate_new_filename(max_filename, options = {})
      current_filename = options[:current_filename]
      current_match_r = current_filename.match(options[:filename_regexp])
      current_number = current_match_r[1].to_i
      max_match_r = max_filename.match(options[:filename_regexp])
      new_number = max_match_r[1].to_i + current_number
      options[:filename_temp].sub("_NUMBER_", new_number.to_s)
    end

    def self.type_filename(filename)
      type_dir = File.basename(File.dirname(filename))
      type_dir == '.' ? File.basename(filename) : File.join(type_dir, File.basename(filename))
    end

    def package=(new_package)
      @package = new_package
      @extract_path = @package.extract_path
    end

    def relationships_part
      xml_fragment.children.select{ |c| c.name == "Relationships" }.first
    end

    def xml_fragment
      Nokogiri::XML.fragment(xml_content)
    end

    def xml_content
      content = nil
      File.open(full_path, 'r') { |file| content = file.read }
      content
    end

    def xml_content=(new_xml)
      File.open(full_path, 'w') { |file| file.write new_xml }
      new_xml
    end

    def full_path
      File.join(extract_path, filename)
    end

    def type_filename
      self.class.type_filename(filename)
    end

    def resource_folder_name
      self.class.resource_folder_name
    end

    def same_group?(resource)
      File.dirname(filename) == File.dirname(resource.filename) &&
        File.extname(filename) == File.extname(resource.filename)
    end

    def generate_new_filename(max_resource = nil)
      if max_resource
        options = {
          current_filename: self.filename,
          filename_regexp: self.class.const_get('FILENAME_REGEXP'),
          filename_temp: self.class.const_get('FILENAME_TEMP'),
        }
        self.class.generate_new_filename(max_resource.filename, options) || self.filename
      else
        self.filename
      end
    end

    def resource_number
      filename_regexp = self.class.const_get('FILENAME_REGEXP')
      match_r = filename.match(filename_regexp)
      match_r ? match_r[1].to_i : 0
    end

    def rename(source_package, new_filename)
      old_filename = self.filename
      old_full_filename = File.join(extract_path, old_filename)
      new_full_filename = File.join(extract_path, new_filename)
      File.rename old_full_filename, new_full_filename

      sources = source_package.try(resource_folder_name)
      if sources.is_a?(Array)
        index = sources.index(self)
        self.filename = new_filename
        sources[index] = self
        source_package.send("#{resource_folder_name}=", sources)
      else
        self.filename = new_filename
        source_package.send("#{resource_folder_name}=", self)
      end

      Powerpoint::Relationship.subclasses.each do |relationship_type|
        r_folder = relationship_type.resource_folder_name
        relationships = source_package.try(r_folder)
        relationships = [relationships] unless relationships.is_a? Array
        relationships.each do |relationship|
          relationship.replace_resource(old_filename, new_filename)
        end
      end

      content_types = source_package.content_types
      content_types.replace_resource(old_filename, new_filename)

      source_package
    end

    def dumplicate_to(target_package)
      target_full_filename = File.join(target_package.extract_path, filename)
      FileUtils.cp full_path, target_full_filename
    end

    def defined_resource?
      content_type? || relationship?
    end

    def content_type?
      false
    end

    def relationship?
      false
    end

    def to_s
      filename
    end
  end
end
