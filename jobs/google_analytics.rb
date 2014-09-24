require 'net/http'
require 'uri'
require 'json'

$config = YAML.load File.open("$config/google_analytics.yml")

current_count = 0

def get_stats(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if uri.scheme === 'https'
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  JSON.parse(response.body)
end


SCHEDULER.every '10s' do
  last_count = current_count
  stats = get_stats($config[:cache_url])
  current_count = stats['data']['ga:activevisitors']
  send_event('active_users', { current: current_count, last: last_count })
end
