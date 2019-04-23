require "open-uri"

class Downloader
  def initialize(gallery)
    @urls = gallery.images.map { |image| image.src }
    _start_downloading
  end

  def _start_downloading
    unless @urls.empty?
      url = @urls.pop
      image = open(url)
      write_path = File.expand_path(File.join("public", "images", image.base_uri.to_s.split("/").last))
      IO.copy_stream(image, write_path)
      _start_downloading
    end
  end
end
