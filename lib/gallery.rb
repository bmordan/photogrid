require "uri"
require "net/http"
require "json"

require_relative "./image"

class Gallery
  attr_reader :id, :title, :keywords
  attr_accessor :images

  def initialize(id, title, keywords, images = [])
    @id = id
    @title = title
    @keywords = keywords
    @images = images
  end
end
