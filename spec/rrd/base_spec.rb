require File.dirname(__FILE__) + "/../spec_helper"

describe RRD::Base do
  
  before do
    @rrd = RRD::Base.new(RRD_FILE)
  end
  
  it "should restore a rrd from xml" do
    RRD::Wrapper.should_receive(:restore).with(XML_FILE, RRD_FILE).and_return(true)
    @rrd.restore(XML_FILE).should be_true
  end
  
  it "should return the date started at" do
    date = 100000
    RRD::Wrapper.should_receive(:first).with(RRD_FILE).and_return(date)
    @rrd.starts_at.should == date
  end
  
  it "should respond to first"
  it "should respond to last"
end