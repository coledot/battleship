class ApplicationController < ActionController::Base
  # disabling CSRF protection for simplicity; NEVER do this in production
  protect_from_forgery with: :null_session

  include Response

  # must restart server to start a new game
  GameState.delete_all
end
