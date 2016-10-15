# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
add_share_buttons = ->
  if $(".share-container").length > 0
    $(".share-container").each (i, elem) ->
      share = VK.Share.button {
        url: "http://vk.com/app4500975",
        title: "N-назад",
        description: "Мой результат: " + $(elem).prev().html()
        },
        {
          type: "link_noicon",
          text: "Опубликовать"
        }
      $(elem).append share
        

$(document).ready add_share_buttons
$(document).on 'page:load', add_share_buttons
