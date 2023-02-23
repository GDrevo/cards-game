Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :players, only: %i[new create]
  resources :battles, only: %i[new create show] do
    patch :play_card, on: :member
    patch :simulate_turn, on: :member
    get 'game_over/:result', to: 'battles#game_over', as: 'game_over'
  end
end
