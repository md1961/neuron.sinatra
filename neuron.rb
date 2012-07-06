
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

