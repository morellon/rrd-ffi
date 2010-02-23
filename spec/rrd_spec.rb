require File.dirname(__FILE__) + "/spec_helper"

describe RRD do
  
  before do
    RRD::Base.new(RRD_FILE).restore(XML_FILE)
  end
  
  it "should create a graph" do
    result = RRD.graph IMG_FILE, :title => "Test", :width => 800, :height => 250 do
      area RRD_FILE, :cpu0 => :average, :color => "#00FF00", :label => "CPU 0"
      line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory"
    end
    
    result.should be_true
  end
end