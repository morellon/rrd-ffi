require File.dirname(__FILE__) + "/../spec_helper"

describe RRD::Wrapper do
  
  context "when no rrd file exists" do
    it "should restore a rrd from xml" do
      RRD::Wrapper.restore(XML_FILE, RRD_FILE).should be_true
    end
    
    it "should create a rrd" do
      RRD::Wrapper.create(RRD_FILE, 
                          "--step", "300", 
                          "DS:ifOutOctets:COUNTER:1800:0:4294967295", 
                          "RRA:AVERAGE:0.5:1:2016").should be_true
      File.should be_file(RRD_FILE)
    end
  end
  
  context "when there is a rrd file" do
    before do
      RRD::Wrapper.restore(XML_FILE, RRD_FILE)
    end
    
    it "should update the rrd file" do
      RRD::Wrapper.update(RRD_FILE, "N:500000000:U:U:U:U:U:U:U:U").should be_true
    end
    
    it "should fetch values" do
      values = RRD::Wrapper.fetch(RRD_FILE, "AVERAGE", "--start", "1266933600", "--end", "1267020000")
      values.should have(26).lines
      values[0][0].should == "time"
      values[1][0].should == 1266933600
      values[1][1].should == 0.0008
      values.last[0].should == 1267020000
    end
    
    it "should return info data about this file" do
      info = RRD::Wrapper.info(RRD_FILE)
      info["filename"].should == RRD_FILE
    end
    
    it "should return the first entered date" do
      RRD::Wrapper.first(RRD_FILE).should == 1266944780
    end
    
    it "should return the last entered date" do
      RRD::Wrapper.last(RRD_FILE).should == 1266945375
    end
    
    it "should create a graph correctly" do
      RRD::Wrapper.graph(IMG_FILE, "DEF:data=#{RRD_FILE}:memory:AVERAGE", "LINE1:data#0000FF:Memory Avg")
      File.should be_file(IMG_FILE)
    end
  end
  
end