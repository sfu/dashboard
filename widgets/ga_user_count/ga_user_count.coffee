class Dashing.GAUserCount extends Dashing.Widget
  ready: ->
    img = $('#ga_activevisitors_sparkline')
    img.attr('data-baseurl', img.attr('src'))

  onData: (data) ->
    img = $('#ga_activevisitors_sparkline')
    img.get(0).src = img.attr('data-baseurl') + '&ts=' + new Date().getTime() if img.length
