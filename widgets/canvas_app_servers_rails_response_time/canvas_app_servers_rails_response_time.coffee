class Dashing.CanvasAppServersRailsResponseTime extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    app_nodes = data.app_nodes
    img = $('#canvas_app_servers_rails_response_time_graph')
    base_url = 'http://stats.its.sfu.ca/render?hideLegend=false&bgcolor=222222&fgcolor=FFFFFF&title=App%20Nodes%20Rails%20Mean%20Response%20Time%20(ms)&yAxisSide=right&width=758&height=350&from=-120minutes&'
    targets = data.app_nodes.map (node) -> "target=alias(stats.timers.canvas.production.canvas-#{node}.rails.responseTime.mean,'#{node}')"
    img_url = base_url + targets.join('&')
    img[0].src = img_url  + '&ts=' + new Date().getTime() if img.length
