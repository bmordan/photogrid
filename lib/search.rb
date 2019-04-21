require "net/http"
require "uri"
require "json"
require_relative "./image"

module Search
  def fetch_images(gallery_id, keywords)
    search_result = _fetch(keywords)

    unless keywords.empty? && search_result["hits"].empty?
      if search_result["hits"].empty?
        fetch_images(gallery_id, keywords.slice(0, keywords.length - 1))
      else
        search_result["hits"].reduce([]) do |memo, hit|
          memo << Image.new(gallery_id, hit)
        end
      end
    end
  end

  def _fetch(keywords)
    key = ENV["PIXABAY_API_KEY"]
    q = URI::encode(keywords.join("+"))
    query = URI("https://pixabay.com/api/?key=#{key}&q=#{q}&image_type=photo")
    response = Net::HTTP.get_response(query)
    JSON.parse(response.body)
  end
end
