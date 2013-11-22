require 'rest-client'
require 'json'

class CqHealth
  attr_reader :shortname

  def initialize(shortname)
    @shortname = shortname
  end

  def stats
    stats = {
      load_average: load_average,
      memory_usage: gauge("memory"),
      html_average_response: timer("response-times.html.mean").round,
      requests_per_minute: requests_per_minute
    }



    # There can only be four!
    # stats[:json_average_response] = timer("response-times.json.mean").round if shortname.match(/author/)

    stats.delete_if {|k,v| v.nil? }
    stats[:status] = status(stats)
    stats
  end

  # Calculate request made in the last minute using continuous request counter
  def requests_per_minute
    data = data "stats.gauges.cq.#{shortname}.request-count"
    return if data.first.nil?
    datapoint_value = data.first.fetch("datapoints").map {|datapoint| datapoint.first }.uniq
    datapoint_value.last - datapoint_value[-2]
  end

  def status(stats)
    return "danger" if stats.fetch(:memory_usage, 0) > 90

    return "danger" if stats.fetch(:load_average, 0) > 10
    return "warning" if stats.fetch(:load_average, 0) > 5

    return "danger" if stats.fetch(:html_average_response, 0) > 2000
    return "warning" if stats.fetch(:html_average_response, 0) > 1000

    return "danger" if stats.fetch(:json_average_response, 0) > 2000
    return "warning" if stats.fetch(:json_average_response, 0) > 1000

    return "warning" if stats.fetch(:requests_per_minute, 0) > 1000
    
    "safe"
  end

  def load_average
    value = gauge("load-average")
    (value/100.0).round(2)
  end

  def gauge(gauge_name)
    stat("stats.gauges.cq.#{shortname}.#{gauge_name}")
  end

  def timer(timer_name)
    stat("stats.timers.cq.#{shortname}.#{timer_name}")
  end

  def stat(target)
    data = data(target)
    unless data.first
      puts "No data found for #{target}"
      return 0
    end

    times = data.first.fetch("datapoints").map {|datapoint| datapoint.first }.compact
    # Smooth out number using average of last 10
    times[-10..-1].reduce(&:+) / 10
  end

  def data(target)
    params = {
      target: target,
      format: "json",
      from: "-20mins"
    }
    response = RestClient.get "http://stats.its.sfu.ca/render/", params: params
    data = JSON.parse(response)
  end
end