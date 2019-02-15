Rails.application.routes.draw do
  get 'connect', to: 'enedis_connections#connect', as: :connect
  devise_for :users
  root to: 'pages#home'
  resources :housings
  resources :profils, only: [:show, :edit, :update]
  get 'profils/:id/validation', to: 'profils#validation', as: :validation_profil
  get 'profils/:id/settings', to: 'profils#settings', as: :settings_profil
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
