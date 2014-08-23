module Powerpoint
  class NotesMaster < PackageResource
    FILENAME_REGEXP = /ppt\/notesMasters\/notesMaster(\d+)\.xml$/
    FILENAME_TEMP   = "ppt/notesMasters/notesMaster_NUMBER_.xml"

    def initialize filename, package
      super(filename, package)
    end
  end
end
