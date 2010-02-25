require File.dirname(__FILE__) + "/../spec_helper"

describe RRD::Builder do
  
  subject {RRD::Builder.new "file.rrd"}
  
  it "should store a datasource" do
    datasource = subject.datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
    datasource.should == "DS:memory:GAUGE:600:0:U"
  end
  
  it "should store an archive" do
    archive = subject.archive :average, :every => 10.minutes, :during => 1.day
    archive.should == "RRA:AVERAGE:0.5:2:144"
  end
  
  it "should create rrd file" do
    
  end
end