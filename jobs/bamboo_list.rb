require 'bamboo_api'

$config = YAML.load File.open("config/bamboo.yml")

SCHEDULER.every '30s' do
  BambooApi.new({
    end_point: $config["bamboo_host"],
    username: $config["bamboo_username"],
    password: $config["bamboo_password"]
  })

  def get_plan_status(plan)
    build = BambooApi::Build.find_by_plan(plan).first
    data = {
      name: build.plan_name,
      build_number: build.number,
      key: build.key,
      username: build.username,
      commit_id: build.vcs_revision_key,
      status: build.state.downcase,
      build_relative_time: build.build_relative_time,
      icon: "icon-#{build.state.downcase}"
    }
    #data[:name].slice! 'Deploy to '
    data[:name] = data[:name].split("Deploy to" )[1]
    data
  end
  
  # Canvas plans
  items = $config["plan_keys"].map { |p| get_plan_status(p) }
  send_event('bamboo_list', { items: items })

  # CQ plans
  items = $config["cq_plan_keys"].map { |p| get_plan_status(p) }
  send_event('cq_bamboo_list', { items: items })
end