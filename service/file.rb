module FileService
  extend self

  def get_file(file)
    [File.expand_path(File.dirname(__FILE__)), '/', file].join
  end
end

