SCHEDULER.every '10s' do
  cq_nodes = Hash[{
    "A2" => "author-p2",
    "P1" => "publisher-p1",
    "P2" => "publisher-p2",
    "P3" => "publisher-p3",
    "P4" => "publisher-p4"
  }.to_a.shuffle]

  cq_nodes.each do |label, shortname|
    health_stats = CqHealth.new(shortname).stats
    health_stats[:label] = label
    send_event "cq_node_status_#{label.downcase}", health_stats
    sleep 1
  end
end