module Powerpoint
  class PresentationRelationship < Relationship
    FILENAME = "ppt/_rels/presentation.xml.rels"

    def self.generate_new_filename(max_filename = nil)
      FILENAME
    end
  end
end
