# Display Canvas node status
# Pull status data from the node status aggregator
# Pull F5 pool information from the F5

require 'f5-icontrol'
require 'resolv'
require 'json'
require 'net/http'
require 'uri'

$config = $config || Hash.new
$config[:f5] = YAML.load File.open("config/f5.yml")
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
    data[node]["f5_pool"] = $pool_members[node][:type] || "-"
    data[node]["f5_status"] = $pool_members[node][:status]
    data[node]["passenger_queue"] ||= "-"
  end

end

SCHEDULER.every '3s', :first_in => '6s' do
  data = get_node_stats
  data = data.values.sort { |a,b| a['server'][2..-1].to_i <=> b['server'][2..-1].to_i }
  send_event('canvas_node_status', {data: data})
end



# update pool members from the F5 every 30s
wsdls = ["LocalLB.PoolMember"]
$f5 = F5::IControl.new($config[:f5][:ip_address], $config[:f5][:username], $config[:f5][:password], wsdls).get_interfaces
f5_pools = {
  :app => ["/Common/canvas.f5lms.sfu.ca_80"],
  :file => ["/Common/files.canvas.f5lms.sfu.ca_80"]
}
def get_pool_members(pool)
  $f5["LocalLB.PoolMember"].get_object_status pool
end
$pool_members = nil
SCHEDULER.every '30s', :first_in => '1s' do
  pool_members = Hash.new
  f5_pools.each do | type, pool_name |
    members = get_pool_members pool_name
    members.first.each do | entry |
      hostname = Resolv.new.getname(entry.member.address)
      hostname = hostname.scan( /\w{2}\d{1,}/ )[0]
      pool_members[hostname] = {
        :type => type,
        :status => entry.object_status.enabled_status
      }
    end
  end
  $pool_members = pool_members
end
