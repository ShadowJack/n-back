$(document).ready ->   
  console.log 'Ready!'
  
  set_close_button()
  
  VK.init ->
    uid = document.location.search.match(/viewer_id=\d+/)[0].slice 10
    console.log "UID: ", uid
    
    VK.addCallback "onApplicationAdded", ->
      $.post '/users.json', {score: 0, options: '2sp', vk_id: uid}
    
    # при нажатии на одну из кнопок меню логинимся в приложении
    $(".menu-item").on 'click', (e) ->
      console.log "Loggin in: ", uid
      # логинимся под текущим uid
      $.post '/login/'+ uid + '.json', (data, status, jqXHR) ->
        # success function 
        console.log "Login status: ", status
        console.log "Logged in: ", data
  , ->
    #onError
    window.top.location = window.top.location
  , '5.21'
  
  
  
set_close_button = ->
  if($(".close-button"))
    $(".close-button").on "click", (event) ->
      console.log $(this.parentNode)
      $(this.parentNode).css("display", "none")
      
$(document).on "page:load", set_close_button