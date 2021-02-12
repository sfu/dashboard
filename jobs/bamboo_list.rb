require 'rest-client'

$config = $config || Hash.new 
$config[:bamboo] = YAML.load File.open("config/bamboo.yml")

def canvas_environments
  url = "https://#{$config[:bamboo]['bamboo_host']}/rest/api/latest/deploy/project/3538945"
  resp = RestClient.get url, { accept: :json, authorization: "Bearer #{$config[:bamboo]["bamboo_token"]}" }
  environments = JSON.parse(resp.body)["environments"]
end

def last_result_for_environment(id)
  url = "https://#{$config[:bamboo]['bamboo_host']}/rest/api/latest/deploy/environment/#{id}/results"
  resp = RestClient.get url, { accept: :json, authorization: "Bearer #{$config[:bamboo]["bamboo_token"]}" }
  resp = JSON.parse(resp.body)
  last_result = resp["results"][0]
end


SCHEDULER.every '30s' do
  environments_whitelist = ["Production", "Stage", "Test"]
  environments = canvas_environments.select! { |e| environments_whitelist.include? e["name"] }

  results = environments.map do |e|
    r = last_result_for_environment(e["id"])
		{
      environment_name: e["name"],
      environment_release: r["deploymentVersion"]["name"],
      status: r["deploymentState"].downcase,
      icon: "icon-#{r['deploymentState'].downcase}",
      date: r["finishedDate"]
    }
  end

  results.sort_by! { |r| r[:environment_name] }
  send_event('bamboo_list', { items: results })
end

