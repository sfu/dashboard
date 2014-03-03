class Dashing.CanvasNodeTable extends Dashing.Widget
  timestampToHoursMinutesSeconds = (timestamp) ->
    timestamp = new Date(timestamp * 1000)
    hours = timestamp.getHours()
    minutes = ("0" + timestamp.getMinutes()).slice(-2)
    seconds = ("0" + timestamp.getSeconds()).slice(-2)
    return "#{hours}:#{minutes}:#{seconds}"

  template = (data) ->
    return [
      '<tr data-server="' + data.server + '">',
      '<td class="status-' + data.status + '">',
      data.server.toUpperCase(),
      '</td><td class="status-' + data.status + '">',
      data.cpu_perc + '%',
      '</td><td class="status-' + data.status + '">',
      data.passenger_queue,
      '</td><td class="status-' + data.status + '">',
      timestampToHoursMinutesSeconds(data.updatedAt),
      ' /td></tr>'
    ].join('')

    @accessor 'node_id', ->
      id = @get('id')
      return id.split('_')[2].toUpperCase()

    onData: (data) ->
      $elem = jQuery('#' + data.server)
      html = template(data);
      # if a row with the same id exists in the table, update it
      targetRow = $('[data-server="' + data.server + '"]')
      if (targetRow.length)
        targetRow.replaceWith(html)
      # otherwise, append a new one
      else
        $('.canvas_node_table tbody').append(html)
