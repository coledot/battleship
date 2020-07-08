class CreateGameStates < ActiveRecord::Migration[6.0]
  def change
    create_table :game_states do |t|
      t.integer :player
      t.integer :turn_num
      t.integer :x_pos
      t.integer :y_pos
      t.string :cell_state

      t.timestamps
    end
  end
end
