module Powerpoint
  class ContentType < PackageResource
    XML_DEFINE = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'

    FILENAME = "[Content_Types].xml"

    def initialize filename, package
      super(filename, package)
    end

    def self.generate_new_filename(max_filename = nil)
      FILENAME
    end

    def replace_resource(old_filename, new_filename)
       _xml_document = Nokogiri::XML(xml_content)
      _types_part = _xml_document.children.select{ |c| c.name == "Types" }.first
      old_type_filename = self.class.type_filename(old_filename)
      new_type_filename = self.class.type_filename(new_filename)
      _types_part.search("Override[PartName]"). \
          select{ |r| r[:PartName] =~ /#{old_type_filename}$/ }.each do |r|
        newPartName = r[:PartName].sub(/#{old_type_filename}$/, new_type_filename)
        r[:PartName] = newPartName
      end
      _types_xml = _types_part.to_xml
      new_xml = "#{self.class.const_get('XML_DEFINE')}\n#{_types_part}"
      self.xml_content = new_xml
    end

    def combine_resource(source_package, source_resource)
      source_xml_document = Nokogiri::XML(source_resource.xml_content)
      source_types_part = source_xml_document.children.select{ |c| c.name == "Types" }.first

      self_xml_document = Nokogiri::XML(self.xml_content)
      self_types_part = self_xml_document.children.select{ |c| c.name == "Types" }.first

      source_types_part.search("Default[Extension]").each do |r|
        next if self_types_part.search("Default[Extension='#{r[:Extension]}']").first
        self_types_part.add_child(r.dup)
      end

      source_types_part.search("Override[PartName]").each do |r|
        next if self_types_part.search("Override[PartName='#{r[:PartName]}']").first
        self_types_part.add_child(r.dup)
      end

      self_types_xml = self_types_part.to_xml
      new_xml = "#{self.class.const_get('XML_DEFINE')}\n#{self_types_xml}"
      self.xml_content = new_xml
    end

    def content_type?
      true
    end
  end
end
