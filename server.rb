require "sinatra"
require_relative "./lib/db"
require_relative "./lib/downloader"

db = DB.new

set :bind, "0.0.0.0"

get /\/|\/galleries/ do
  erb :galleries, :locals => { :galleries => db.get_galleries }, :layout => :layout
end

get "/gallery/create" do
  erb :gallery_create
end

get "/gallery/:id" do
  erb :gallery, :locals => { :gallery => db.get_gallery(params["id"]) }
end

post "/gallery" do
  gallery_id = db.create_gallery(params["title"])
  erb :gallery_create_keyword, :locals => { :keyword_count => 0, :gallery_id => gallery_id }
end

post "/gallery/create/keyword" do
  keyword_count = db.add_keyword(params["gallery_id"], params["keyword"])

  if keyword_count < 3
    erb :gallery_create_keyword, :locals => { :keyword_count => keyword_count, :gallery_id => params["gallery_id"] }
  else
    gallery = db.add_images(params["gallery_id"])
    Downloader.new(gallery)
    erb :gallery, :locals => { :gallery => gallery }
  end
end
