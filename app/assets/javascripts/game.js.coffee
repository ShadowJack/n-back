$(document).ready ->
  console.log "Document is ready!"
  #Если есть поле для игры, то играем
  if $("#game_field")
    $.get "/users.json", (data, status, xhr) ->
      console.log "From /users.json - data: ", data
      if data.error || status != 200
        console.log "Something wrong has happend when getting user info: ", data.error
        return
    