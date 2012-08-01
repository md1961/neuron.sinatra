
require 'sinatra'

require 'model/neuron_loggedin'


DEFAULT_DAYS_TO_SHOW = 3


get '/' do
  redirect '/detailed'
end

get '/detailed' do
  date_from = get_date_from
  @loggedins = NeuronLoggedin.all(from: date_from)
  haml :detailed
end

get '/max_user_by_hour' do
  date_from = get_date_from
  @timestamp_and_max_users = NeuronLoggedin.max_user_by_hour(from: date_from)
  haml :max_user_by_hour
end

get '/max_user_by_date' do
  @timestamp_and_max_users = NeuronLoggedin.max_user_by_date
  haml :max_user_by_date
end


helpers do
  def current?(path)
    path == request.path_info
  end

  def link_to_unless_current(path, label)
    current?(path) ? "<b>#{label}</b>" : "<a href='#{url(path)}'>#{label}</a>"
  end

  def get_date_from
    if params[:days]
      days_to_date_from([params[:days].to_i, DEFAULT_DAYS_TO_SHOW].max)
    else
      params[:from] || default_date_from
    end
  end

  def default_date_from
    days_to_date_from(DEFAULT_DAYS_TO_SHOW)
  end

  def days_to_date_from(days)
    (Date.today - days + 1).strftime(NeuronLoggedin::DATE_FORMAT)
  end
end

