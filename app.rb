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

before '/tasks' do
  if current_user.nil?
    redirect '/'
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
    name: params[:name],
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

get '/tasks/new' do
  erb :new
end

post '/tasks' do
  date = params[:due_date].split('-')
  list = List.find(params[:list])
  if Date.valid_date?(date[0].to_i, date[1].to_i, date[2].to_i)
    current_user.tasks.create(title: params[:title], due_date: Date.parse(params[:due_date]), list_id: list.id)
    redirect '/'
  else
    redirect '/tasks/new'
  end
end


get '/post' do
  erb :index
end

post '/post' do

  if current_user.nil? then
    redirect '/'
  else
    current_user.posts.create(artist: params[:artist], album: params[:album],track: params[:track],sample_image: params[:sample_image], image_url: params[:image_url], sample_url: params[:sample_url], comment: params[:comment], user_name: current_user.name, user_id: current_user.id)
  end

  redirect '/'

end

# ---------------------------------------------------------- #

post '/tasks/:id' do
  task = Task.find(params[:id])
  list = List.find(params[:list])
  date = params[:due_date].split('-')

  if Date.valid_date?(date[0].to_i, date[1].to_i, date[2].to_i)
    task.title = CGI.escapeHTML(params[:title])
    task.due_date = Date.parse(params[:due_date])
    task.list_id = list.id
    task.save
    redirect '/'
  else
    redirect "/tasks/#{task.id}/edit"
  end
end

post '/tasks/:id/done' do
  task = Task.find(params[:id])
  task.completed = true
  task.save
  redirect '/'
end

get '/tasks/:id/star' do
  task = Task.find(params[:id])
  task.star = !task.star
  task.save
  redirect '/'
end

post '/tasks/:id/delete' do
  task = Task.find(params[:id])
  task.destroy
  redirect '/'
end

get '/tasks/:id/edit' do
  @task = Task.find(params[:id])
  erb :edit
end

get '/tasks/over' do
  @lists = List.all
  @tasks = current_user.tasks.due_over
  erb :index
end

get '/tasks/done' do
  @lists = List.all
  @tasks = current_user.tasks.where(completed: true)
  erb :index
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
  # redirect '/search'
end