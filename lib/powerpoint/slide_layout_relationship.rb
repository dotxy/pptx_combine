module Powerpoint
  class SlideLayoutRelationship < Relationship
    FILENAME_REGEXP = /ppt\/slideLayouts\/_rels\/slideLayout(\d+)\.xml\.rels$/
    FILENAME_TEMP   = "ppt/slideLayouts/_rels/slideLayout_NUMBER_.xml.rels"
  end
end
