require 'bundler/capistrano'

set :application, "dashboard"
set :repository, "git@github.com:sfu/dashboard.git"  # Your clone URL
set :scm, "git"
set :use_sudo, false
set :user, "rails"
set :ssh_options, { :forward_agent => true }
set :deploy_to, "/home/rails/apps/#{application}"
set :normalize_asset_timestamps, false

default_run_options[:shell] = '/bin/bash --login'

server "rails1.its.sfu.ca", :app, :web, :db, :primary => true

after 'deploy:update_code' do
  run "cp #{shared_path}/config/* #{release_path}/config"
end

after "deploy", "deploy:cleanup"

# after "deploy" do
#   run "sudo restart dashboard"
# end
