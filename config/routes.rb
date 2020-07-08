Rails.application.routes.draw do
  get 'battleship_app/index'

  resources :game_state

  root 'battleship_app#index'
end
