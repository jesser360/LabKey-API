Rails.application.routes.draw do
  resources :animals
    root 'pages#home'
    get '/housing', to: 'animals#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
