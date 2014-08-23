module Powerpoint
  class SlideMaster < PackageResource
    FILENAME_REGEXP = /ppt\/slideMasters\/slideMaster(\d+)\.xml$/
    FILENAME_TEMP   = "ppt/slideMasters/slideMaster_NUMBER_.xml"

    def initialize filename, package
      super(filename, package)
    end
  end
end
