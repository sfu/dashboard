require 'net/http'
require 'uri'
require 'json'

config = YAML.load File.open("config/canvas.yml")

def get_enrollments(canvas_url, canvas_token)
  uri = URI.parse(canvas_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if uri.scheme === 'https'
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri, {"Authorization" => canvas_token})

  response = http.request(request)
  JSON.parse(response.body)
end

SCHEDULER.every '3h', :first_in => '45s' do
  enrollments = get_enrollments(config[:url_base] + config[:enrollments][:path], config[:auth_token])
  data = []
  enrollments["unique"].each do |key,value|
    label = key.dup
    label.slice! 'Enrollment'
    label.upcase! if label === 'Ta'
    label = "#{label}s"
    data << { 'label' => label, 'value' => value }
  end
  send_event('enrollments', {items: data})
end
