# app.rb
require 'sinatra'

get '/' do
  erb params[:name]
end

