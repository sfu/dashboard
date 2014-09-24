require 'rest-client'
require 'json'

$config = YAML.load File.open("config/cq.yml")

def published_pages(cq_node)
  response = RestClient.get url(cq_node).to_s, params: {
    type: "cq:Page",
    path: "/content/sfu"
  }
  data = JSON.parse(response)
  data.fetch("total").to_i.humanize
end

def published_assets(cq_node)
  response = RestClient.get url(cq_node).to_s, params: {
    type: "dam:Asset",
    path: "/content/dam/sfu"
  }
  data = JSON.parse(response)
  data.fetch("total").to_i.humanize
end

def top_level_sites(cq_node)
  response = RestClient.get url(cq_node).to_s, params: {
    type: "cq:Page",
    path: "/content",
    nodename: "sfu",
    "p.limit" => "1",
    "p.hits" => "full",
    "p.nodedepth" => 1
  }
  data = JSON.parse(response)

  # Mungle the data to find out how many children
  sfu_node_data = data.fetch("hits").first
  sfu_node_data.delete_if {|k, v| !v.is_a?(Hash) }
  sfu_node_data.keys.count.humanize
end

def url(cq_node)
  url = URI.parse cq_node.fetch(:hostname)
  url.user = cq_node.fetch(:username)
  url.password = cq_node.fetch(:password)
  url.path = "/bin/querybuilder.json"
  url
end

class Fixnum
  def humanize
    self.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
  end
end

SCHEDULER.every '10s' do
  cq_node = $config[:publisher_p4]

  stats = {
    "Top-level Sites" => top_level_sites(cq_node),
    "Published Pages" => published_pages(cq_node),
    "Published Assets" => published_assets(cq_node)
  }

  data = []
  stats.each do |label, value|
    data << { label: label, value: value }
  end

  send_event('cq_stats', {items: data})
end
