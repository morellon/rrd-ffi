require File.dirname(__FILE__) + "/../spec_helper"

describe RRD::Graph do
    
  before do
    RRD::Base.new(RRD_FILE).restore(XML_FILE)
    @graph = RRD::Graph.new IMG_FILE
  end
  
  xit "should create a graph correctly" do
    @graph.line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory Avg"
    #@graph.should_receive(:rrd_graph).with("").and_return 0
    @graph.save
    
    File.should be_file(IMG_FILE)
  end
  
end