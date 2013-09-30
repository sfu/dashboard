require 'google/api_client'
require 'date'

current_count = 0

SCHEDULER.every '60s' do
  last_count = current_count

  client = Google::APIClient.new({
    :application_name => 'Canvas Dashboard',
    :application_version => '1.0'
  })

  # Load our credentials for the service account
  key = Google::APIClient::KeyUtils.load_from_pkcs12("#{settings.root}/#{settings.google_analytics[:key_file]}", 'notasecret')
  client.authorization = Signet::OAuth2::Client.new(
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
    :audience => 'https://accounts.google.com/o/oauth2/token',
    :scope => 'https://www.googleapis.com/auth/analytics.readonly',
    :issuer => settings.google_analytics[:service_account_email],
    :signing_key => key)

  # Request a token for our service account
  client.authorization.fetch_access_token!

  analytics = client.discovered_api('analytics','v3')

  startDate = DateTime.now.prev_day.strftime("%Y-%m-%d")
  endDate = DateTime.now.strftime("%Y-%m-%d")

  results = client.execute(:api_method => analytics.data.realtime.get, :parameters => {
    'ids' => settings.google_analytics[:profile_id],
    'start-date' => startDate,
    'end-date' => endDate,
    'metrics' => "ga:activeVisitors",
    'fields' => "totalsForAllResults"
  })

  current_count = results.data.totals_for_all_results['ga:activeVisitors']
  send_event('active_users', { current: current_count, last: last_count })

end
