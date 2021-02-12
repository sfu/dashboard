pad_start = (num, places) -> 
  zero = places - num.toString().length + 1
  Array(+(zero > 0 && zero)).join("0") + num

class Dashing.CanvasAppServersRailsResponseTime extends Dashing.Widget

  ready: ->
    img = $('#canvas_app_servers_rails_response_time_graph')
    num_nodes = 20
    nodes = [1..num_nodes]
    base_url = 'http://stats.its.sfu.ca/render?hideLegend=false&bgcolor=222222&fgcolor=FFFFFF&title=App%20Nodes%20Rails%20Mean%20Response%20Time%20(ms)&yAxisSide=right&width=758&height=350&from=-120minutes&'
    targets = nodes.map (node) -> "target=alias(stats.timers.canvas.production.lcp-canvas-ap#{pad_start(node, 2)}.rails.responseTime.mean,'ap#{pad_start(node, 2)}')"
    img_url = base_url + targets.join('&')
    img[0].src = img_url  + '&ts=' + new Date().getTime() if img.length
