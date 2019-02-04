Rails.application.routes.draw do
  get 'connect', to: 'enedis_connections#connect', as: :connect
  devise_for :users
  root to: 'pages#home'
  resources :housings
  resources :profils, only: [:show, :edit, :update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
