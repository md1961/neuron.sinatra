
require 'sinatra'

require 'model/neuron_loggedin'


DEFAULT_DAYS_TO_SHOW = 7
DEFAULT_DATE_FROM = (Date.today - DEFAULT_DAYS_TO_SHOW + 1).strftime(NeuronLoggedin::DATE_FORMAT)


get '/' do
  redirect '/detailed'
end

get '/detailed' do
  @loggedins = NeuronLoggedin.all(from: DEFAULT_DATE_FROM)
  haml :detailed
end

get '/max_user_by_hour' do
  @hour_and_max_users = NeuronLoggedin.max_user_by_hour(from: DEFAULT_DATE_FROM)
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

