
require 'sinatra'

require 'model/neuron_loggedin'


DEFAULT_DAYS_TO_SHOW = 7


get '/' do
  redirect '/detailed'
end

get '/detailed' do
  redirect "/detailed/#{default_date_from}"
end

get '/detailed/:date_from' do
  date_from = params[:date_from]
  @loggedins = NeuronLoggedin.all(from: date_from)
  haml :detailed
end

get '/max_user_by_hour' do
  @hour_and_max_users = NeuronLoggedin.max_user_by_hour(from: default_date_from)
  haml :max_user_by_hour
end

get '/max_user_by_date' do
  @date_and_max_users = NeuronLoggedin.max_user_by_date
  haml :max_user_by_date
end


helpers do
  def current?(path)
    path.split('/')[1] == request.path_info.split('/')[1]
  end

  def link_to_unless_current(path, label)
    current?(path) ? "<b>#{label}</b>" : "<a href='#{url(path)}'>#{label}</a>"
  end

  def default_date_from
    (Date.today - DEFAULT_DAYS_TO_SHOW + 1).strftime(NeuronLoggedin::DATE_FORMAT)
  end
end

