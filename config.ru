require 'dashing'
require 'yaml'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :default_dasbhoard, 'canvas'

  Dir.glob('config/*.yml').each do |f|
    config_name = File.basename(f, '.*')
    raw_config = File.read(f)
    config = YAML.load(raw_config).symbolize_keys
    set config_name.to_sym, Proc.new { config }
  end

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
