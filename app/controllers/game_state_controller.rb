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
    player_num = params[:id].to_i

    last_turn = latest_game_state(player_num)
    if last_turn.nil?
      json_response(game_state: nil, message: "Game has not started yet!")
    else
      json_response(game_state: last_turn, message: nil)
    end
  end

  # /POST
  def create
    player_num = params[:player].to_i

    if whose_turn != player_num
      return json_response(game_state: nil, message: "It's not your turn, please wait")
    end

    opponent_num = player_num == 1 ? 2 : 1
    x_pos, y_pos = params[:x_pos], params[:y_pos]

    target_cell = GameState.select('cell_state, turn_num, max(turn_num)').
                            where(player: opponent_num, x_pos: x_pos, y_pos: y_pos).first

    if ["miss", "hit"].include?(target_cell.cell_state)
      return json_response(game_state: latest_game_state(player_num), message: "You've already fired on this location!")
    end

    new_state = target_cell.cell_state == 'empty' ? 'miss' : 'hit'
    GameState.new(player: opponent_num, turn_num: current_turn_number + 1,
                  x_pos: x_pos, y_pos: y_pos, cell_state: new_state).save

    msg = "Fired on position (#{x_pos}, #{y_pos}); it was a #{new_state}"
    return json_response(game_state: latest_game_state(player_num), message: msg)
  end

  private

  def player_ready(player_num)
    GameState.where(player: player_num, turn_num: 0).length > 0
  end

  def new_game(player_num)
    ship_coords = generate_ship_coords
    populate_cells_with_state(player_num, ship_coords, :ship)
    empty_coords = all_coords - ship_coords
    populate_cells_with_state(player_num, empty_coords, :empty)
    GameState.where(player: player_num, turn_num: 0)
  end

  def populate_cells_with_state(player_num, coords, cell_state)
    coords.each do |coord|
      GameState.new(player: player_num, turn_num: 0,
                    x_pos: coord[0], y_pos: coord[1], cell_state: cell_state).save
    end
  end

  def all_coords
    (0...10).map do |x|
      (0...10).map do |y|
        [x,y]
      end
    end.flatten(1)
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

  def generate_ship_coords
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

  def whose_turn
    current_turn_number.even? ? 1 : 2
  end

  def current_turn_number
    GameState.maximum(:turn_num).to_i
  end

  def latest_game_state(player_num)
    redact_game_state(player_num, GameState.select('*, max(turn_num)').group(:x_pos, :y_pos))
  end

  def redact_game_state(player, game_state)
    game_state.each do |cell|
      if cell.player != player && cell.cell_state == 'ship'
        # hide opponent's ship positions from the player
        cell.cell_state = :empty
      end
    end
  end
end
