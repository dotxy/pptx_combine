module Powerpoint
  class Slide < PackageResource
    FILENAME_REGEXP = /ppt\/slides\/slide(\d+)\.xml$/
    FILENAME_TEMP   = "ppt/slides/slide_NUMBER_.xml"

    def initialize filename, package
      super(filename, package)
    end
  end
end
