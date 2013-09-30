class Dashing.Graphite extends Dashing.Widget

  ready: ->
    if @get('interval')
      interval = parseInt(@get('interval'))
    else
      interval = 60000
    self = this
    setInterval ->
      self.updateGraph()
    , interval
    @updateGraph()

  updateGraph: ->
    url = @get('image')
    $n = $(@node)
    width = $n.width()
    height = $n.height()

    url = @updateUrl url, 'width', width
    url = @updateUrl url, 'height', height
    url = @updateUrl url, '_uniq', new Date().getTime()

    $n.find('img').attr 'src', url

  updateUrl: (url, param, value) ->
    if url.indexOf(param) >= 0
      regexp = new RegExp '([\?&])' + param + '(=[^&]*)?&?'
      url = url.replace regexp, '$1'

    repl = param + '=' + value

    if url.indexOf('?') < 0
      url + '?' + repl
    else
      url + '&' + repl
