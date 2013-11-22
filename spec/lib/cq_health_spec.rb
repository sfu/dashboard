require 'spec_helper'

describe CqHealth do
  let(:cq_health) { CqHealth.new("author-p2") }

  it "is instantiated with a CQ host shortname" do
    cqHealth = CqHealth.new("author-p2")
    cqHealth.shortname.should == "author-p2"
  end

  it "has some stats" do
    cq_health.stats.should be_a Hash
  end

  describe "#stats" do
    it "removes nil values from the returned hash" do
      cq_health.should_receive(:requests_per_minute).and_return(nil)
      cq_health.stats[:requests_per_minute].should be_nil
    end
  end

  describe "#requests_per_minute" do
    it "returns the difference between the last two differing values in the request-count" do
      cq_health.should_receive(:data).and_return([{"datapoints"=>[[48895.0, 1385157420], [49830.0, 1385157430], [49830.0, 1385157440], [49830.0, 1385157450], [49830.0, 1385157460], [49830.0, 1385157470], [49830.0, 1385157480], [50053.0, 1385157490], [50053.0, 1385157500], [50053.0, 1385157510], [50053.0, 1385157520], [50053.0, 1385157530], [50053.0, 1385157540], [50215.0, 1385157550], [50215.0, 1385157560], [50215.0, 1385157570], [50215.0, 1385157580], [50215.0, 1385157590], [50215.0, 1385157600], [50388.0, 1385157610], [50388.0, 1385157620], [50388.0, 1385157630], [50388.0, 1385157640], [50388.0, 1385157650], [50388.0, 1385157660], [51188.0, 1385157670], [51188.0, 1385157680], [51188.0, 1385157690], [51188.0, 1385157700], [51188.0, 1385157710], [51188.0, 1385157720], [51302.0, 1385157730], [51302.0, 1385157740], [51302.0, 1385157750], [51302.0, 1385157760], [51302.0, 1385157770], [51302.0, 1385157780], [51419.0, 1385157790], [51419.0, 1385157800], [51419.0, 1385157810], [51419.0, 1385157820], [51419.0, 1385157830], [51419.0, 1385157840], [51593.0, 1385157850], [51593.0, 1385157860], [51593.0, 1385157870], [51593.0, 1385157880], [51593.0, 1385157890], [51593.0, 1385157900], [51792.0, 1385157910], [51792.0, 1385157920], [51792.0, 1385157930], [51792.0, 1385157940], [51792.0, 1385157950], [51792.0, 1385157960], [51909.0, 1385157970], [51909.0, 1385157980], [51909.0, 1385157990], [51909.0, 1385158000], [51909.0, 1385158010]]}])
      cq_health.requests_per_minute.should == 51909.0 - 51792.0
    end

    it "returns nil when unknown" do
      cq_health.should_receive(:data).and_return([])
      cq_health.requests_per_minute.should be_nil
    end
  end
end