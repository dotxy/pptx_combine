module Powerpoint
  class NotesSlideRelationship < Relationship
    FILENAME_REGEXP = /ppt\/notesSlides\/_rels\/notesSlide(\d+)\.xml\.rels$/
    FILENAME_TEMP   = "ppt/notesSlides/_rels/notesSlide_NUMBER_.xml.rels"
  end
end
