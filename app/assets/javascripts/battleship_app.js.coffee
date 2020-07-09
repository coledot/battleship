CELL_STATES = ['empty', 'ship', 'miss', 'hit']

@replaceState = (cell, new_state)->
  for possible_state in CELL_STATES
    cell.removeClass(possible_state)
   cell.addState(new_state)

@gridSelector = (player)->
  "#player_#{player}_grid"

@playerGridSelector = ->
  gridSelector(document.playerNumber)

@opponentGridSelector = ->
  gridSelector(if document.playerNumber == 1 then 2 else 1)

@fillBoardState = (game_state)->
  for state in game_state
    selector = gridSelector(state.player) + " #row#{state.y_pos}_col#{state.x_pos}"
    $(selector).addClass(state.cell_state)

@updateMessages = (new_message)->
  msg_box = $('.message_box')
  messages = msg_box.children()
  return if messages.last().text() == new_message
  if messages.length > 8
    messages.first().remove()
  msg_box.append("<p>#{new_message}</p>")

@processStateResponse = (data, _, __)->
  if data.game_state != null
    # FIXME this is an ugly way to do it
    if document.playerNumber == undefined
      document.playerNumber = data.game_state[0].player
      $(playerGridSelector() + " .grid_title").append(" (You)")
      $(opponentGridSelector() + " .grid_title").append(" (Opponent)")
    fillBoardState data.game_state
  if data.message != null
    updateMessages data.message

@pollGameState = ->
  $.get("game_state/#{document.playerNumber}", @processStateResponse)

@fireOnCell = ->
  grid_id = $(@).parent().parent().attr('id')
  if grid_id == "player_#{document.playerNumber}_grid"
    updateMessages "You can't fire on your own fleet!"
    return

  cell_id = $(@).attr('id')
  row_col_re = /row(\d+)_col(\d+)/
  row_col_match = cell_id.match row_col_re
  x_pos = row_col_match[2]
  y_pos = row_col_match[1]

  post_params = { player: document.playerNumber, x_pos: x_pos, y_pos: y_pos }
  $.post("game_state", post_params, processStateResponse)

@startGame = ->
  $.get("game_state", @processStateResponse)
  # FIXME ideally we would be updated by the server when the game is ready instead of polling it,
  #       but c'est la vie
  setInterval(pollGameState, 1000)

window.onload = ->
  @startGame()
  $(document).on("click", ".grid_cell", @fireOnCell)
