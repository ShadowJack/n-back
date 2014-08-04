# Если есть поле для игры, то играем
if $("#game_field")
  $.get("/users.json"), (data, status, xhr) ->
    console.log "From /users.json - data: ", data