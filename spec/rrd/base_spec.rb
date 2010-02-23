require File.dirname(__FILE__) + "/../spec_helper"

describe RRD::Base do
  
  before do
    @rrd = RRD::Base.new(RRD_FILE)
  end
  
  it "should restore a rrd from xml" do
    @rrd.restore(XML_FILE).should be_true
  end
  
  it "should respond to first"
  it "should respond to last"
end