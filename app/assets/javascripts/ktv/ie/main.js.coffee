window.App = {}
App.preload = (arrayOfImages) ->
  $(arrayOfImages).each(->
    $('<img/>')[0].src = this
  )
