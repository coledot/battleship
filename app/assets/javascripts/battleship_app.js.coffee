CELL_STATES = ['empty', 'ship', 'miss', 'hit']

@replaceState = (cell, new_state)->
  for possible_state in CELL_STATES
    cell.removeClass(possible_state)
   cell.addState(new_state)

@gridSelector = (player)->
  "#player_" + player + "_grid"

@playerGridSelector = ->
  gridSelector(document.playerNumber)

@opponentGridSelector = ->
  gridSelector(if document.playerNumber == 1 then 2 else 1)

@fillBoardState = (game_state)->
  for state in game_state
    selector = gridSelector(state.player) + " #row" + state.y_pos + "_col" + state.x_pos
    $(selector).addClass(state.cell_state)

@updateMessages = (message)->
  # TODO rolling msg buffer
  $('.message_box').append("<p>" + message + "</p>")

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
  $.ajax(type: 'GET', url: "game_state/" + document.playerNumber, success: @processStateResponse)

@startGame = ->
  $.ajax(type: 'GET', url: "game_state", success: @processStateResponse)
  # FIXME ideally we would be updated by the server when the game is ready instead of polling it,
  #       but c'est la vie
  setInterval(pollGameState, 1000)

window.onload = @startGame
