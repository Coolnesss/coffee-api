Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/state', to: 'coffee#state', as: 'state'
  root 'coffee#state'
end
