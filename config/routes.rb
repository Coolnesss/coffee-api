Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post '/sample', to: 'coffee#sample', as: 'sample'
  get '/state', to: 'coffee#state', as: 'state'
  root 'coffee#state'
  require 'crono/web'
    Crono::Web.use Rack::Auth::Basic do |username, password|
      username == ENV["CRONO_USERNAME"] && password == ENV["CRONO_PASSWORD"]
    end
    mount Crono::Web, at: '/crono'

end
