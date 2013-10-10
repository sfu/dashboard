require 'dashing'
require 'yaml'
require 'SecureRandom'

configure do
  set :default_dasbhoard, 'canvas'
  set :auth_token, ENV['AUTH_TOKEN'] || SecureRandom.uuid

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

module Rufus::Scheduler
  class Job
    old_trigger = self.instance_method(:trigger)

    define_method(:trigger) do
      unless Sinatra::Application.connections.empty?
        old_trigger.bind(self).call
      end
    end
  end
end


map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
