require 'rest-client'

$config = YAML.load File.open("$config/cq.yml")

def workflow_stats(cq_info)
  url = URI.parse cq_info.fetch(:hostname)
  url.user = cq_info.fetch(:username)
  url.password = cq_info.fetch(:password)
  url.path = "/bin/querybuilder.json"

  running_workflows = active_workflows(url.to_s)
  stale_workflows = stale_workflows(url.to_s)

  [
    { status: "active", value: running_workflows.fetch("total") },
    { status: "stale",  value: stale_workflows.fetch("total") -  running_workflows.fetch("total") }
  ]
end

def stale_workflows(url)
  response = RestClient.get url.to_s, params: {
    type: "cq:Workflow",
    path: "/etc/workflow/instances",
    property: "status",
    "property.value" => "RUNNING"
  }
  data = JSON.parse(response)
end

def active_workflows(url)
  response = RestClient.get url.to_s, params: {
    type: "cq:Workflow",
    path: "/etc/workflow/instances",
    property: "status",
    "property.value" => "RUNNING",
    "daterange.property" => "startTime",
    "daterange.lowerBound" => ten_minutes_ago.to_datetime.iso8601
  }
  data = JSON.parse(response)
end

def ten_minutes_ago
  Time.now - 60*10
end

SCHEDULER.every '30s' do
  stats = workflow_stats($config[:author_p2])
  send_event 'author_workflow_stats', { items: stats }
end