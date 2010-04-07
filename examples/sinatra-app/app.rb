%w( rubygems sinatra ../../lib/rack/webauth ).each { |lib| require lib }

enable :sessions

use Rack::Webauth do
  set_application 'Rack::Webauth on Sinatra'
  set_url 'http://sinatra-app.local/'
  set_local_login '/login'
end

helpers Rack::Webauth::Helpers

get '/' do
  session.inspect
end

get '/blocked' do
  login_required
  session[:webauth].inspect
end

get '/login' do
  erb :login
end

post '/login' do
  login!
end

get '/logout' do
  logout!
end

get '/favicon.ico' do
  ''
end
