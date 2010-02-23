require "spec_helper"

describe RRD do
  
  before do
    @rrd_file = File.dirname(__FILE__) + "/vm.rrd"
    @xml_file = File.dirname(__FILE__) + "/vm.xml"
    @img_file = File.dirname(__FILE__) + "/vm.png"
    @rrd = RRD.new(@rrd_file)
    
    [@rrd_file, @img_file].each{|file| FileUtils.rm file rescue nil}
  end
  
  it "should restore a rrd from xml" do
    @rrd.restore(@xml_file).should be_true
  end
  
  it "should create a graph" do
    result = RRD.graph @img_file, :title => "Test", :width => 800, :height => 250 do
      line @rrd_file, :memory => :average, :color => "#0000FF", :label => "Memory"
      area @rrd_file, :cpu0 => :average, :color => "#00FF00", :label => "CPU 0"
    end
    
    result.should be_true
  end
  
  it "should respond to first"
  it "should respond to last"
end