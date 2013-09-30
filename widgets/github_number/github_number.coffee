class Dashing.GithubNumber extends Dashing.Widget

  onData: (data) ->

     # clear existing "status-*" classes
    $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
    # add new class
    if !(data.hasOwnProperty('status'))
        levels = ['safe', 'warning', 'danger']
        thresholds = {
            github_pull_requests: [0, 1, 3],
            github_branch_comparison: [0, 3, 5]
        }

        if thresholds[data.id].indexOf(data.current) > -1
            level = thresholds[data.id].indexOf(data.current)
        else
            if data.current >= thresholds[data.id][2]
                level = levels[2]
            else if data.current >= thresholds[data.id][1]
                level = levels[1]
            else
                level = levels[0]
        $(@get('node')).addClass "status-#{level}"
    else
        $(@get('node')).addClass "status-#{data.status}"
