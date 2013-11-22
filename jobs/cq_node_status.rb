require 'rest-client'
require 'json'

def health_stats(label, hostname)
  health_stats = {
    load_average: load_average(hostname),
    memory_usage: gauge(hostname, "memory"),
    html_average_response: timer(hostname, "response-times.html.mean").round,
    label: label
  }

  health_stats[:json_average_response] = timer(hostname, "response-times.json.mean").round if label.match(/A/)
  health_stats[:status] = status(health_stats)

  health_stats
end

def status(health_stats)
  return "danger" if health_stats.fetch(:memory_usage, 0) > 90

  return "danger" if health_stats.fetch(:load_average, 0) > 10
  return "warning" if health_stats.fetch(:load_average, 0) > 5

  return "danger" if health_stats.fetch(:html_average_response, 0) > 2000
  return "warning" if health_stats.fetch(:html_average_response, 0) > 1000

  return "danger" if health_stats.fetch(:json_average_response, 0) > 2000
  return "warning" if health_stats.fetch(:json_average_response, 0) > 1000
  
  "safe"
end

def load_average(hostname)
  value = gauge(hostname, "load-average")
  (value/100.0).round(2)
end

def gauge(hostname, gauge_name)
  stat("stats.gauges.cq.#{hostname}.#{gauge_name}")
end

def timer(hostname, timer_name)
  stat("stats.timers.cq.#{hostname}.#{timer_name}")
end

def stat(target)
  params = {
    target: target,
    format: "json",
    from: "-10mins"
  }
  response = RestClient.get "http://stats.its.sfu.ca/render/", params: params
  data = JSON.parse(response)
  return -1 unless data.first
  times = data.first.fetch("datapoints").map {|datapoint| datapoint.first }.compact
  # Smooth out number using average of last 10
  times[-10..-1].reduce(&:+) / 10
end

SCHEDULER.every '10s' do
  cq_nodes = Hash[{
    "A2" => "author-p2",
    "P1" => "publisher-p1",
    "P2" => "publisher-p2",
    "P3" => "publisher-p3",
    "P4" => "publisher-p4"
  }.to_a.shuffle]

  cq_nodes.each do |label, hostname|
    health_stats = health_stats(label, hostname)
    send_event "cq_node_status_#{label.downcase}", health_stats
    sleep 1
  end
end