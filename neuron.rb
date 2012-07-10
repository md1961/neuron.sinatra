
require 'sinatra'

require 'model/neuron_loggedin'


get '/' do
  redirect '/detailed'
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


helpers do
  def current?(path)
    path == request.path_info
  end

  def link_to_unless_current(path, label)
    current?(path) ? "<b>#{label}</b>" : "<a href='#{url(path)}'>#{label}</a>"
  end
end

