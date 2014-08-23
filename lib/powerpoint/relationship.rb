module Powerpoint
  class Relationship < PackageResource
    XML_DEFINE = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    RID_REGEXP = /rId(\d+)$/
    RID_TEMP   = "rId_NUMBER_"

    def initialize filename, package
      super(filename, package)
    end

    def self.relationship_id_number(rId)
      match_r = rId.match(const_get('RID_REGEXP'))
      match_r ? match_r[1].to_i : 0
    end

    def described_resource_folder_name
      resource_folder_name.sub('_relationship', '')
    end

    def described_resource_filename
      filename.sub('_rels/', '').sub(/\.rels$/, '')
    end

    def described_resource(package)
      resources = package.try(described_resource_folder_name)
      resources = [resources] unless resources.is_a? Array
      resources.select{ |r| r.filename == described_resource_filename }.first
    end

    def replace_resource(old_filename, new_filename)
      _xml_document = Nokogiri::XML(xml_content)
      _relationships_part = _xml_document.children.select{ |c| c.name == "Relationships" }.first
      old_type_filename = self.class.type_filename(old_filename)
      new_type_filename = self.class.type_filename(new_filename)
      _relationships_part.search("Relationship[Target]"). \
          select{ |r| r[:Target] =~ /#{old_type_filename}$/ }.each do |r|
        newTarget = r[:Target].sub(/#{old_type_filename}$/, new_type_filename)
        r[:Target] = newTarget
      end
      _relationships_xml = _relationships_part.to_xml
      new_xml = "#{self.class.const_get('XML_DEFINE')}\n#{_relationships_xml}"
      self.xml_content = new_xml
    end

    def dummy_combine_resource(source_package, target_resource)
      target_xml_document = Nokogiri::XML(target_resource.xml_content)
      target_relationships_part = target_xml_document.children.select{ |c| c.name == "Relationships" }.first
      max_target_rid_number = target_relationships_part.search("Relationship[Id]") \
        .map{ |r| self.class.relationship_id_number(r[:Id]) } \
        .sort{ |a, b| b <=> a }.first

      self_described_resource = described_resource(package)
      self_described_resource_xml_content = self_described_resource.xml_content

      self_xml_document = Nokogiri::XML(self.xml_content)
      self_relationships_part = self_xml_document.children.first
      self_relationships_part.search("Relationship[Id]") \
          .sort{ |a, b| self.class.relationship_id_number(b[:Id]) <=> \
            self.class.relationship_id_number(a[:Id]) } \
          .each do |r|
        oldId = r[:Id]
        newNumber = self.class.relationship_id_number(oldId) + max_target_rid_number
        newId = self.class.const_get('RID_TEMP').sub("_NUMBER_", newNumber.to_s)
        r[:Id] = newId
        self_described_resource_xml_content.sub!("r:id=\"#{oldId}\"", "r:id=\"#{newId}\"")
      end
      self_described_resource.xml_content = self_described_resource_xml_content
      self_relationships_xml = self_relationships_part.to_xml
      new_xml = "#{self.class.const_get('XML_DEFINE')}\n#{self_relationships_xml}"
      self.xml_content = new_xml
    end

    def combine_resource(source_package, source_resource)
      source_xml_document = Nokogiri::XML(source_resource.xml_content)
      source_relationships_part = source_xml_document.children.select{ |c| c.name == "Relationships" }.first

      self_xml_document = Nokogiri::XML(self.xml_content)
      self_relationships_part = self_xml_document.children.select{ |c| c.name == "Relationships" }.first

      source_relationships_part.search("Relationship[Target]").each do |r|
        next if self_relationships_part.search("Relationship[Target='#{r[:Target]}']").first
        self_relationships_part.add_child(r.dup)
      end

      self_relationships_xml = self_relationships_part.to_xml
      new_xml = "#{self.class.const_get('XML_DEFINE')}\n#{self_relationships_xml}"
      self.xml_content = new_xml
    end

    def relationship?
      true
    end
  end
end
