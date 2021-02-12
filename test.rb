require 'resolv'
require 'json'
require 'net/http'
require 'uri'
require 'yaml'

$config = $config || Hash.new
$config[:dashboard_node_status] = YAML.load File.open("config/dashboard_node_status.yml")


# pull status information from the aggregator every 10s
def get_node_stats
  path = '/service/canvas-nsx'
  http = Net::HTTP.new($config[:dashboard_node_status][:hostname], $config[:dashboard_node_status][:port])
  request = Net::HTTP::Get.new(path)
  response = http.request(request)
  data = JSON.parse(response.body)
  data.each do | node, stats |
    data[node] = JSON.parse(stats)
    data[node]["passenger_queue"] ||= "-"
  end

end

  data = get_node_stats
  #puts data.inspect
  data = data.values.sort { |a,b| a['server'][2..-1].to_i <=> b['server'][2..-1].to_i }
  puts data.inspect
