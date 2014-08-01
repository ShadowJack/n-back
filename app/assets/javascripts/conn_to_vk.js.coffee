$(document).ready ->
  console.log 'Ready!'
  VK.init ->
    uid = document.location.search.match(/viewer_id=\d+/)[0].slice 10
    console.log "UID: ", uid
    VK.addCallback "onApplicationAdded", ->
      $.post '/users.json', {score: 0, options: '2sp', vk_id: uid}
    # логинимся под текущим uid
    $.post '/login/'+ uid + '.json', (data, status, jqXHR) ->
      # success function 
      console.log "Login status: ", status
      console.log "Logged in: ", data.response
  , ->
    #onError
    window.top.location = window.top.location
  , '5.21'