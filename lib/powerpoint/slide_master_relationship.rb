module Powerpoint
  class SlideMasterRelationship < Relationship
    FILENAME_REGEXP = /ppt\/slideMasters\/_rels\/slideMaster(\d+)\.xml\.rels$/
    FILENAME_TEMP   = "ppt/slideMasters/_rels/slideMaster_NUMBER_.xml.rels"
  end
end
