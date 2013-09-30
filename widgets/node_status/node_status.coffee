class Dashing.NodeStatus extends Dashing.Widget
    @accessor 'node_id', ->
        id = @get('id')
        return id.split('_')[2].toUpperCase()

    onData: (data) ->

      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      $(@get('node')).addClass "status-#{data.status}"

