play = ->
  #Если есть поле для игры, то играем
  if $("#game_field").length != 0
    console.log "Found #game_field"
    $.get "/user.json", (data, status, xhr) ->
      console.log "From /users.json - data: ", data
      if data.error
        console.log "Something wrong has happend when getting user info: ", data.error
        return
        
$(document).ready play
$(document).on "page:load", play
  
    