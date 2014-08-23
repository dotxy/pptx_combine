module Powerpoint
  class NotesSlide < PackageResource
    FILENAME_REGEXP = /ppt\/notesSlides\/notesSlide(\d+)\.xml$/
    FILENAME_TEMP   = "ppt/notesSlides/notesSlide_NUMBER_.xml"

    def initialize filename, package
      super(filename, package)
    end
  end
end
