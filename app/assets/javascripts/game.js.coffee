# глобальными делаем переменные, к которым мы должны иметь доступ из коллбэков внутри setInterval
resources_loaded = false
seq = []
num = 2
options = []
game_on = false
scene_elem = null
user = null
timebar_width = 0
times_to_show = 0
vk_id = ""

play = ->
  #Если есть поле для игры, то играем
  game_on = false
  console.log "Game_on: ", game_on
  if $("#game_field").length != 0
    console.log "Location: ", document.location
    vk_id = document.location.search.match(/vk_id=\d+/)[0].slice 6
    console.log "Found #game_field"
    $.get "/user.json?vk_id=" + vk_id, (data, status, xhr) ->
      console.log "From /users.json - data: ", data
      if data.error
        console.log "Something wrong has happend when getting user info: ", data.error
        return
      user = data
      options = data.options.split("")
      num = parseInt options[0]
      options = options[1..-1]
      console.log "Player options: ", options
      # Генерируем последовательность длиной 15 + nsteps*2 + opts_len*2
      times_to_show = 15 + num*2 + options.length*2
      seq = generate_sequence(times_to_show , options)
      counter = 0
      interval = window.setInterval(->
        if resources_loaded || counter >= 20
          clearInterval interval
          onGameReady()
        counter += 1
      , 100)

# возвращает букву, соответствующую нажатой клавише в нижнем регистре
getChar = (event) ->
  if event.which == null #IE
    if event.keyCode < 32 then return null # спец. символ
    return (String.fromCharCode event.keyCode).toLowerCase()
 
  if event.which != 0 && (event.charCode != 0 || event.keyCode != 0) # все кроме IE
    if event.which < 32 then return null
    return (String.fromCharCode event.which).toLowerCase()
  return null


onGameReady = ->
  # Поочередно вызываем события и проверяем нажатие пользователем кнопок
  game_on = true
  accuracy = {} # {"s": {all: 6, right: 4, wrong: 2}, "p": {all: 4, right: 3, wrong: 1}, ...}
  for opt in options
    accuracy[opt] = {"all": 0, "right": 0, "wrong": 0}
  nback_seq_index = -num
  curr_seq_index = 0
  keys_pressed = []
  
  show_time = 2000 + 500 * options.length # период показа
  
  if $("#timebar").length > 0
    timebar_width = $("#timebar").width()
    timer = window.setInterval ->
      width = $("#timebar").width()
      $("#timebar").css 'width', (width - 2)
    , show_time / 100 # из расчета, что убираем по 2 пикселя 100 раз

  # Key press events
  $(window).on 'keydown', (e) ->
    char = getChar e
    key_to_option_mapping =
      "s": "s", #звук
      "d": "f", #форма
      "k": "p", #позиция
      "l": "c"  #цвет
    return if key_to_option_mapping[char] == null || options.indexOf(key_to_option_mapping[char]) == -1
    keys_pressed.push(key_to_option_mapping[char])
    $('.ctrl-btn[value="' + key_to_option_mapping[char] + '"]').addClass("active")
    setTimeout ->
      $('.ctrl-btn[value="' + key_to_option_mapping[char] + '"]').removeClass("active")
    , 400
       
  $(".ctrl-btn").on 'click', (e)->
    keys_pressed.push($(this).prop("value"))

  game_loop = window.setInterval ->
    if !game_on
      window.clearInterval game_loop
      window.clearInterval timer
      return
    nback_seq_elem = (nback_seq_index >= 0 && seq[nback_seq_index] || {})
    if nback_seq_elem != {}
      # чистим массив нажатых клавиш от дубликатов
      keys_pressed = keys_pressed.filter (item, pos, self) =>
        self.indexOf(item) == pos

      # проверяем, совпадают ли признаки в текущем элементе и н-назад
      similar = []
      for k,v of nback_seq_elem
        if seq[curr_seq_index][k] == v
          similar.push(k)
      for o in similar
        accuracy[o]["all"] += 1
      # смотрим все нажатия и определяем правильные и неправильные
      for key in keys_pressed
        if similar.indexOf(key) != -1 # мы нажали правильную кнопку
          accuracy[key]["right"] += 1
        else
          accuracy[key]["wrong"] += 1
    # если ещё не могло быть повторений, но кнопка была нажата, то это ошибка
    else if keys_pressed.length > 0
      for k in keys_pressed
        accuracy[k]["wrong"] += 1

    keys_pressed = [] # обнуляем массив нажатых кнопок
    nback_seq_index += 1
    curr_seq_index += 1
    if curr_seq_index == seq.length
      window.clearInterval game_loop
      console.log "Finish!"
      console.log "Accuracy: ", accuracy
      onGameEnd(accuracy)
      return
    show_seq_elem(curr_seq_index)
  , show_time
  
onGameEnd = (acc) ->
  if user == null
    console.log "User is empty!"
    return
  result = [] # "s6-4-5 p15-3-1" -> "s": {all: 6, right: 4, wrong: 5}, "p": {all: 15, right: 3, wrong: 1}
  for k, v of acc
    result.push(k + v["all"] + "-" + v["right"] + "-" + v["wrong"])
  console.log "Posting ", result
  $.post '/progress_entries.json?vk_id=' + vk_id, {nsteps: num, result: result.join(" ")}, (data, response, xhr) ->
    console.log "saved entry: ", data
    window.location.replace '/results?vk_id=' + vk_id

show_seq_elem = (index) ->
  # убираем предыдущий элемент
  if scene_elem != null
    scene_elem.parentNode.removeChild(scene_elem)
  curr_elem = seq[index]
  scene_elem = document.createElement('div')
  console.log "Current elem: ", curr_elem
  if options.indexOf("s") != -1
    curr_elem["s"].play()
  if options.indexOf("f") != -1
    scene_elem.className = curr_elem["f"]
    img = new Image()
    img.src = '/img/circle.png'
    img.src = '/img/triangle.png'
    img.src = '/img/plus.png'
    img.src = '/img/pentagon.png'
  else
    scene_elem.className = "square"
  if options.indexOf("c") != -1
    scene_elem.style.backgroundColor = curr_elem["c"]
  else
    scene_elem.style.backgroundColor = "#258520"
  if options.indexOf("p") != -1
    $(curr_elem["p"]).append(scene_elem)
  else
    $("#cell4").append(scene_elem)
  # восстанавливаем таймбар
  if $("#timebar").length > 0
    $("#timebar").css 'width', timebar_width
    # показываем, сколько раз еще осталось
    $("#timebar").text (times_to_show - index)
  
loadAlphabet = (count) ->
  resources = ["А", "Г", "Е", "И", "Л", "Н", "О", "П", "Р", "С", "Т", "Ю", "Я"].map((val, index, arr) -> "/audio/" + val + ".ogg")
  loadedAudioCounter = 0
  res = []
  
  load_audio = (uri) ->
    audio = new Audio()
    audio.addEventListener 'canplaythrough', onSoundLoaded, false
    audio.src = uri
    return audio
  
  onSoundLoaded = ->
    loadedAudioCounter += 1
    console.log "loadedAudio: ", loadedAudioCounter
    if loadedAudioCounter >= count
      console.log "All sounds loaded"
      resources_loaded = true
  
  for i in [0..(count-1)]
    if resources.length == 0
      break
    rand_index = Math.floor(Math.random()*resources.length)
    res.push(load_audio(resources[rand_index]))
    resources.splice rand_index, 1
  return res
  
generate_sequence = (count, options) ->
  seq = []
  if options.indexOf("s") != -1
    # загружаем звук
    sounds = loadAlphabet(9)
  else
    resources_loaded = true
  if options.indexOf("p") != -1
    positions = ["#cell0", "#cell1", "#cell2", "#cell3", "#cell4", "#cell5", "#cell6", "#cell7", "#cell8"]
  if options.indexOf("f") != -1
    forms = ["square", "circle", "triangle", "pentagon", "plus"]
  if options.indexOf("c") != -1
    colors = ["#A82424", "#DCC028", "#258520", "#14147A", "#7E4631", "#030303", "#03F2FA"]
  
  for i in [0..(count-1)]
    curr_elem = {}
    for opt in options
      if i < num || Math.random() < 1 - 3 / count # генерим любое
        switch opt
          when "s" then curr_elem["s"] = sounds[Math.floor(Math.random()*sounds.length)]
          when "p" then curr_elem["p"] = positions[Math.floor(Math.random()*positions.length)]
          when "f" then curr_elem["f"] = forms[Math.floor(Math.random()*forms.length)]
          when "c" then curr_elem["c"] = colors[Math.floor(Math.random()*colors.length)]
      else # генерим правильный ответ
        switch opt
          when "s" then curr_elem["s"] = seq[i-num]["s"]
          when "p" then curr_elem["p"] = seq[i-num]["p"]
          when "f" then curr_elem["f"] = seq[i-num]["f"]
          when "c" then curr_elem["c"] = seq[i-num]["c"]
    seq.push curr_elem
  seq
  


  
$(document).ready play
$(document).on "page:load", play
  
    
