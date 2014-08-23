module Powerpoint
  class SlideRelationship < Relationship
    FILENAME_REGEXP = /ppt\/slides\/_rels\/slide(\d+)\.xml\.rels$/
    FILENAME_TEMP   = "ppt/slides/_rels/slide_NUMBER_.xml.rels"
  end
end
