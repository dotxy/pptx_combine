module Powerpoint
  class Presentation < PackageResource
    XML_DEFINE = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    FILENAME = "ppt/presentation.xml"

    def initialize filename, package
      super(filename, package)
    end

    def self.generate_new_filename(max_filename = nil)
      FILENAME
    end

    # TODO
    def combine_resource(source_package, source_resource)
      source_xml_document = Nokogiri::XML(source_resource.xml_content)
      source_presentation_part = source_xml_document.children.select{ |c| c.name == "presentation" }.first

      self_xml_document = Nokogiri::XML(self.xml_content)
      self_presentation_part = self_xml_document.children.select{ |c| c.name == "presentation" }.first

      source_presentation_part.elements.each do |element|
        if element.name.in?(["sldIdLst"])
          self_element = self_presentation_part.elements.select { |e| e.name == element.name }.first
          offset_count = self_element.children.count
          element.children.each do |child_elem|
            new_child_elem = child_elem.dup
            if new_child_elem[:id]
              new_child_elem[:id] = (new_child_elem[:id].to_i + offset_count).to_s
            end
            self_element.add_child new_child_elem
          end
        else
          # Do nothing
        end
      end

      self_presentation_xml = self_presentation_part.to_xml
      new_xml = "#{self.class.const_get('XML_DEFINE')}\n#{self_presentation_xml}"
      self.xml_content = new_xml
    end
  end
end
