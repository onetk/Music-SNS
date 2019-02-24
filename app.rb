require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'

require 'itunes-search-api'
require 'json'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

get '/' do
  @posts = Post.all
  erb :index
end


# ---------------------------------------------------------- #

get '/signup' do

  erb :sign_up
end

post '/signup' do
  user = User.create(
    name: CGI.escapeHTML(params[:name]),
    password: params[:password],
    password_confirmation: params[:password_confirmation],
    profile_image: "https://res.cloudinary.com/dcksv5swp/image/upload/v1549968178/qusyecxamstqbg0lejdz.png"
  )
  if user.persisted?
    session[:user] = user.id
  end
  redirect '/'
end

# ---------------------------------------------------------- #

post '/signin' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

# ---------------------------------------------------------- #

get '/signout' do
  session[:user] = nil
  redirect '/'
end

# ---------------------------------------------------------- #

get '/post' do
  erb :index
end

post '/post' do

  if current_user.nil? then
    redirect '/'
  else
    current_user.posts.create(artist: params[:artist], album: params[:album],track: params[:track],sample_image: params[:sample_image], image_url: params[:image_url], sample_url: params[:sample_url], comment: CGI.escapeHTML(params[:comment]), user_name: current_user.name, user_id: current_user.id)
  end

  redirect '/'

end

# ---------------------------------------------------------- #

post '/posts/:id' do
  post = Post.find(params[:id])

  post.comment = CGI.escapeHTML(params[:comment])
  post.save
  redirect '/'

end

post '/posts/:id/delete' do
  post = Post.find(params[:id])
  post.destroy
  redirect '/'
end

get '/posts/:id/edit' do
  @post = Post.find(params[:id])
  erb :edit
end

# ---------------------------------------------------------- #

get "/search" do

  @Lists=""
  erb :search

end

post "/search" do

  if params[:keyword].match(/.+/) then
    @Lists=ITunesSearchAPI.search(
      :term    => params[:keyword],
      :media   => 'music',
      :limit  => '10')
    # ).each do |item|
    #   p item
    # end
    # p @Lists[0]#["artistName"]
  end
  erb :search
end

# ---------------------------------------------------------- #

get "/home" do
  @myposts = Post.where(user_name: current_user.name)
  erb :home
end