require File.dirname(__FILE__) + "/../spec_helper"

describe RRD::Graph do
    
  before do
    RRD::Base.new(RRD_FILE).restore(XML_FILE)
    @graph = RRD::Graph.new IMG_FILE
  end
  
  it "should create a graph correctly" do
    @graph.line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory Avg"
    RRD::Wrapper.should_receive(:graph).with(IMG_FILE,
                                            "DEF:d0=#{RRD_FILE}:memory:AVERAGE",
                                            "LINE1:d0#0000FF:Memory Avg").and_return true
    @graph.save
  end
  
end