require 'github_api'

$config = $config || Hash.new
$config[:github] = YAML.load File.open("config/github.yml")

def get_status_label(id, value)
  levels = ['safe', 'warning', 'danger']
  thresholds = {
    "github_pull_requests" => [0, 1, 3],
    "github_branch_comparison" => [0, 3, 5]
  }

  level = levels[0]

  if thresholds[id].index value
    level = levels[thresholds[id].index value]
  else
    if value >= thresholds[id][2]
      level = levels[2]
    elsif value >= thresholds[id][1]
      level = levels[1]
    end
  end
  level
end


SCHEDULER.every '1m', :first_in => '20s' do
  github = Github.new basic_auth: "#{$config["username"]}:#{$config["token"]}"
  pulls = github.pulls.all 'sfu', 'canvas-lms'
  compare = github.repos.commits.compare 'sfu', 'canvas-lms', 'sfu-deploy', 'sfu-develop'

  send_event('github_pull_requests', { current: pulls.count, status: get_status_label('github_pull_requests', pulls.count) })
  send_event('github_branch_comparison', { current: compare.ahead_by, status: get_status_label('github_branch_comparison', compare.ahead_by) })
end
