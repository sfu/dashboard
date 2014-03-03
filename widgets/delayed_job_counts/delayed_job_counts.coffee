class Dashing.DelayedJobCounts extends Dashing.Widget

  onData: (data) ->
    console.log(data)
    $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''

    failed = null
    thresholds = [0, 1, 5]
    levels = ['safe', 'warning', 'danger']
    data.items.forEach (metric) ->
      failed = metric if metric.status is 'failed'
    if failed
      if thresholds.indexOf(failed.value) > -1
        level = levels[thresholds.indexOf(failed.value)]
      else
        if failed.value >= thresholds[2]
          level = levels[2]
        else if failed.value >= thresholds[1]
          level = levels[1]
        else
          level = levels[0]
      $(@get('node')).addClass "status-#{level}"

