require 'rest-client'

def workflow_stats(cq_info)
  url = URI.parse cq_info.fetch(:hostname)
  url.user = cq_info.fetch(:username)
  url.password = cq_info.fetch(:password)
  url.path = "/bin/querybuilder.json"

  response = RestClient.get url.to_s, params: {
    type: "cq:Workflow",
    path: "/etc/workflow/instances",
    property: "status",
    "property.value" => "RUNNING"
  }
  data = JSON.parse(response)

  [
    { status: "active", value: data["total"] }
  ]
end

SCHEDULER.every '5s' do
  # CQ author
  stats = workflow_stats(settings.cq[:author_p2])
  
  send_event 'author_workflow_stats', { items: stats }
end