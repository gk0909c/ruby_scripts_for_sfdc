# this module operate files
module FileService
  module_function

  # specify file path from root
  def get_file(file)
    absolute_dir = [File.dirname(__FILE__), '/../'].join
    [File.expand_path(absolute_dir), '/', file].join
  end
end
