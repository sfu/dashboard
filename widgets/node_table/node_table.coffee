class Dashing.NodeTable extends Dashing.Widget
  sortCompare = (a, b) ->
    a = parseInt(a.cells[0].textContent.substr(2), 10)
    b = parseInt(b.cells[0].textContent.substr(2), 10)
    a - b

  sortTable = (table) ->
    tBody = table.tBodies[0]
    rows = Array.prototype.slice.call(tBody.rows, 0)
    rows = rows.sort(sortCompare)
    i = 0
    while i < rows.length
      tBody.appendChild(rows[i])
      ++i

  timestampToHoursMinutesSeconds = (timestamp) ->
    timestamp = new Date(timestamp * 1000)
    hours = timestamp.getHours()
    minutes = ("0" + timestamp.getMinutes()).slice(-2)
    seconds = ("0" + timestamp.getSeconds()).slice(-2)
    "#{hours}:#{minutes}:#{seconds}"

  template = (data) ->
    [
      '<tr data-server="' + data.server + '">',
      '<td class="status-' + data.status + '">',
      data.server.toUpperCase(),
      '</td><td class="status-' + data.status + '">',
      data.cpu_perc + '%',
      '</td><td class="status-' + data.status + '">',
      data.passenger_queue,
      '</td><td class="status-' + data.status + '">',
      timestampToHoursMinutesSeconds(data.updatedAt),
      '</td></tr>'
    ].join('')

  @accessor 'node_id', ->
    id = @get('id')
    id.split('_')[2].toUpperCase()

  onData: (data) ->
    html = template(data);
    $table = $(this.node).find('table');
    # if a row with the same id exists in the table, update it
    targetRow = $('[data-server="' + data.server + '"]')
    if (targetRow.length)
      targetRow.replaceWith(html)
    # otherwise, append a new one
    else
      $table.append(html)
    sortTable($table.get(0));
