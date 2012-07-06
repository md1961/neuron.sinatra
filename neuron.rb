
require 'sinatra'

require 'model/neuron_loggedin'


get '/' do
  haml :index
end

get '/detailed' do
  @loggedins = NeuronLoggedin.all
  haml :detailed
end

