module Powerpoint
  class Media < PackageResource
    def initialize filename, package
      super(filename, package)
    end

    def generate_new_filename(max_resource = nil)
      if max_resource
        max_filename = max_resource.filename
        file_dirname = File.dirname(max_filename)
        file_extname = File.extname(max_filename)
        max_basename = File.basename(max_filename, file_extname)
        match_r = max_basename.match(/\d+/)
        matched_number = match_r[0].to_i
        new_number = matched_number + 1
        new_basename = max_basename.sub(matched_number.to_s, new_number.to_s)
        new_filename = "#{new_basename}#{file_extname}"
        file_dirname == '.' ? new_filename : File.join(file_dirname, new_filename)
      else
        self.filename
      end
    end

    def resource_number
      file_extname = File.extname(filename)
      basename = File.basename(filename, file_extname)
      match_r = basename.match(/\d+/)
      match_r ? match_r[0].to_i : 0
    end
  end
end
