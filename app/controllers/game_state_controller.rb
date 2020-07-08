class GameStateController < ApplicationController
  # /GET
  def index
    if player_ready(2)
      json_response(game_state: nil, message: "A game is already in progress!")
    elsif player_ready(1)
      json_response(game_state: new_game(2), message: "You are Player 2, game is ready")
    else
      json_response(game_state: new_game(1), message: "New game started, you are Player 1")
    end
  end

  # /GET/:id
  def show
    last_turn = GameState.where(player: params[:id], turn_num: GameState.maximum(:turn_num))
    if last_turn.nil?
      json_response(game_state: nil, message: "Game has not started yet!")
    else
      json_response(game_state: last_turn, message: nil)
    end
  end

  # /POST
  def create
    # TODO
  end

  private

  def player_ready(player_num)
    GameState.where(player: player_num, turn_num: 0).length > 0
  end

  def new_game(player_num)
    generate_ships.each do |occupied_cell|
      state = GameState.new(player: player_num, turn_num: 0,
                            x_pos: occupied_cell[0], y_pos: occupied_cell[1], cell_state: :ship)
      state.save
    end
    GameState.where(player: player_num, turn_num: 0)
  end

  def new_positions_valid?(new_positions, existing_positions)
    new_positions.each do |new_pos|
      if new_pos[0] > 9 || new_pos[1] > 9
        # outside grid, try again
        return false
      end
    end

    # set intersection -- if empty, then no collisions
    existing_positions & new_positions == []
  end

  def generate_ships
    occupied_positions = []
    [5, 4, 3, 3, 2].each do |length|
      loop do
        direction = [:horizontal, :vertical].sample
        head_position = [Random.rand(0...10), Random.rand(0...10)]

        newly_occupied_positions = []
        (0...length).each do |offset|
          if direction == :horizontal
            newly_occupied_positions << [head_position[0] + offset, head_position[1]]
          else
            newly_occupied_positions << [head_position[0], head_position[1] + offset]
          end
        end

        if new_positions_valid? newly_occupied_positions, occupied_positions
          # no collisions, move on to next ship
          occupied_positions.push(*newly_occupied_positions)
          break
        end
        # if we get here there is a collision and we need to try again
      end
    end

    occupied_positions
  end
end
