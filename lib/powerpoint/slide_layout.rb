module Powerpoint
  class SlideLayout < PackageResource
    FILENAME_REGEXP = /ppt\/slideLayouts\/slideLayout(\d+)\.xml$/
    FILENAME_TEMP   = "ppt/slideLayouts/slideLayout_NUMBER_.xml"

    def initialize filename, package
      super(filename, package)
    end
  end
end
