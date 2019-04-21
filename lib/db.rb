require "sqlite3"
require_relative "./gallery"
require_relative "./search"

class DB
  include Search

  def initialize
    @db = SQLite3::Database.new ("./db")
    @db.execute "CREATE TABLE IF NOT EXISTS galleries(id INTEGER PRIMARY KEY, title TEXT);"
    @db.execute "CREATE TABLE IF NOT EXISTS keywords(id INTEGER PRIMARY KEY, keyword TEXT, gallery_id INTEGER);"
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS images(
        id INTEGER PRIMARY KEY,
        gallery_id INTEGER,
        src TEXT,
        photographer TEXT,
        photographer_avatar TEXT,
        likes INTEGER,
        tags TEXT
      );
    SQL
  end

  def get_galleries
    galleries = []
    @db.execute("SELECT * FROM galleries;") { |gallery|
      id, title = gallery
      keywords = get_keywords(id)
      images = get_images(id)
      galleries << Gallery.new(id, title, keywords, images)
    }
    return galleries
  end

  def get_keywords(id)
    @db.execute("SELECT * FROM keywords WHERE gallery_id IS ?;", id)
      .reduce([]) { |memo, row| memo << row[1] }
  end

  def get_gallery(id)
    @db.execute("SELECT * FROM galleries WHERE id IS ?;", id) { |gallery|
      id, title = gallery
      keywords = get_keywords(id)
      images = get_images(id)
      return Gallery.new(id, title, keywords, images)
    }
  end

  def create_gallery(title)
    @db.execute("INSERT INTO galleries (title) VALUES (?)", title)
    @db.last_insert_row_id
  end

  def add_keyword(gallery_id, keyword)
    @db.execute("INSERT INTO keywords (keyword, gallery_id) VALUES (?, ?);", [keyword, gallery_id])
    count = @db.execute("SELECT COUNT(id) AS result FROM keywords WHERE gallery_id IS ?;", gallery_id)
    count.first.last
  end

  def get_images(gallery_id)
    @db.execute("SELECT * FROM images WHERE gallery_id IS ?;", gallery_id).reduce([]) { |memo, image|
      memo << Image.new(gallery_id, image)
    }
  end

  def add_images(gallery_id)
    gallery = get_gallery(gallery_id)
    gallery.images = fetch_images(gallery.id, gallery.keywords)
    gallery.images.each { |image| @db.execute("INSERT INTO images (gallery_id, src, photographer, photographer_avatar, likes, tags) VALUES (?, ?, ?, ?, ?, ?);", image.props) }
    return gallery
  end
end
