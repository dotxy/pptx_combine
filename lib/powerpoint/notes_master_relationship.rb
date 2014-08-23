module Powerpoint
  class NotesMasterRelationship < Relationship
    FILENAME_REGEXP = /ppt\/notesMasters\/_rels\/notesMaster(\d+)\.xml\.rels$/
    FILENAME_TEMP   = "ppt/notesMasters/_rels/notesMaster_NUMBER_.xml.rels"
  end
end
