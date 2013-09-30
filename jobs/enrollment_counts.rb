require 'net/http'
require 'uri'
require 'json'

def get_enrollments
  canvas_url = 'http://icat-graham-canvas.its.sfu.ca/sfu/stats/enrollments/current.json'
  canvas_token = 'Bearer 5xER8zBxDEjJuxUI1krHcC2u33goefCQ5zanAOKSss1IBltBkQerze2v0ZKXjnw7'

  uri = URI.parse(canvas_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if uri.scheme === 'https'
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri, {"Authorization" => canvas_token})

  response = http.request(request)
  JSON.parse(response.body)
end

SCHEDULER.every '3h', :first_in => 0 do
  enrollments = get_enrollments
  data = []
  enrollments["unique"].each do |key,value|
    label = key.dup
    label.slice! 'Enrollment'
    label.upcase! if label === 'Ta'
    data << { 'label' => label, 'value' => value }
  end
  send_event('enrollments', {items: data})
end
