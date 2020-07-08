Rails.application.routes.draw do
  get 'battleship_app/index'

  root 'battleship_app#index'
end
