
require 'sinatra'

require 'model/neuron_loggedin'


set :port, 9090


get '/' do
  haml :index
end

get '/detailed' do
  @loggedins = NeuronLoggedin.all
  haml :detailed
end

get '/max_user_by_hour' do
  @hour_and_max_users = NeuronLoggedin.max_user_by_hour
  haml :max_user_by_hour
end

get '/max_user_by_date' do
  @date_and_max_users = NeuronLoggedin.max_user_by_date
  haml :max_user_by_date
end

