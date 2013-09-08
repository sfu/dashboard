require 'bamboo_api'
require 'yaml'
config = YAML.load(File.read('./config/bamboo.yml')) rescue "No config/bamboo.yml file found."

BambooApi.new({
  end_point: config[:bamboo_host],
  username: config[:bamboo_username],
  password: config[:bamboo_password]
})

def get_plan_status(plan)
  build = BambooApi::Build.find_by_plan(plan).first
  data = {
    name: build.plan_name,
    build_number: build.number,
    key: build.key,
    username: build.username,
    commit_id: build.vcs_revision_key,
    status: build.state,
    build_relative_time: build.build_relative_time
  }
end

SCHEDULER.every '30s', :first_in => 0 do
  items = config[:plan_keys].map { |p| get_plan_status(p) }
  send_event('bamboo_list', { items: items })
end
