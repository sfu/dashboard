# Display Canvas node status
# Pull status data from the node status aggregator
# Pull F5 pool information from the F5

require 'resolv'
require 'json'
require 'net/http'
require 'uri'

$config = $config || Hash.new
$config[:dashboard_node_status] = YAML.load File.open("config/dashboard_node_status.yml")

def pool_name(node)

end

# pull status information from the aggregator every 10s
def get_node_stats
  path = '/service/canvas'
  http = Net::HTTP.new($config[:dashboard_node_status][:hostname], $config[:dashboard_node_status][:port])
  request = Net::HTTP::Get.new(path)
  response = http.request(request)
  data = JSON.parse(response.body)
  data.each do | node, stats |
    data[node] = JSON.parse(stats)
    data[node]["passenger_queue"] ||= "-"
  end

end

SCHEDULER.every '3s', :first_in => '6s' do
  data = get_node_stats
  data.delete("query")
  data.delete("search")
  data = data.values.sort { |a,b| a['server'][2..-1].to_i <=> b['server'][2..-1].to_i }
  send_event('canvas_node_status', {data: data})
end


