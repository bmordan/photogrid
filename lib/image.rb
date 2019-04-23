class Image
  attr_reader :gallery_id, :src, :url, :photographer, :photographer_avatar, :likes, :tags, :props

  def initialize(id, result)
    @gallery_id = id

    if result.is_a? Array
      _id, gallery_id, src, photographer, photographer_avatar, likes, tags = result
      @src = src
      @photographer = photographer
      @photographer_avatar = photographer_avatar
      @likes = likes
      @tags = tags
    else
      @src = result["webformatURL"]
      @photographer = result["user"]
      @photographer_avatar = result["userImageURL"]
      @likes = result["likes"]
      @tags = result["tags"]
    end
  end

  def url
    File.join("", "images", @src.split("/").last)
  end

  def props
    [@gallery_id, @src, @photographer, @photographer_avatar, @likes, @tags]
  end
end
