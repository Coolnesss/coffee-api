Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post '/samples', to: 'samples#create', as: 'create_sample'
  get '/state', to: 'coffee#state', as: 'state'
  get '/samples', to: 'samples#not_verified', as: "all_samples"
  put '/samples/:id', to: 'samples#verify', as: "verify_sample"
  delete '/samples/:id', to: 'samples#destroy', as: "deny_sample"
  root 'coffee#state'
  require 'crono/web'
    Crono::Web.use Rack::Auth::Basic do |username, password|
      username == ENV["CRONO_USERNAME"] && password == ENV["CRONO_PASSWORD"]
    end
    mount Crono::Web, at: '/crono'

end
