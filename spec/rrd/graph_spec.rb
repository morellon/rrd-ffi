require "spec_helper"

describe RRD::Graph do
    
  before do
    RRD::Base.new(RRD_FILE).restore(XML_FILE)
    @graph = RRD::Graph.new IMG_FILE, :title => "Title", :width => 800, :height => 200, :full_size_mode => true
  end
  
  it "should store definition for rrd data" do
    result = @graph.for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE
    result.should == "DEF:cpu0=#{RRD_FILE}:cpu0:AVERAGE"
  end
  
  it "should store definition for calculated data" do
    result = @graph.using_calculated_data "half_mem", :calc => "mem,2,/"
    result.should == "CDEF:half_mem=mem,2,/"
  end
  
  it "should store definition for static value" do
    result = @graph.using_value "mem_avg", :calc => "mem,AVERAGE"
    result.should == "VDEF:mem_avg=mem,AVERAGE"
  end
  
  it "should store printable for line drawing" do
    result = @graph.draw_line :data => "mem", :color => "#0000FF", :label => "Memory", :width => 1
    result.should == "LINE1:mem#0000FF:Memory"
  end
  
  it "should store printable for area drawing" do
    result = @graph.draw_area :data => "cpu", :color => "#00FF00", :label => "CPU 0"
    result.should == "AREA:cpu#00FF00:CPU 0"
  end
  
  it "should store printable for comment" do
    result = @graph.print_comment "Lero lero"
    result.should == "COMMENT:Lero lero"
  end
  
  it "should store printable for static value" do
    result = @graph.print_value "mem_avg", :format => "%6.2lf %SB"
    result.should == "GPRINT:mem_avg:%6.2lf %SB"
  end
  
  it "should store definition and printable for line" do
    result = @graph.line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory Avg"
    result[0].should == "DEF:memory_average=#{RRD_FILE}:memory:AVERAGE"
    result[1].should == "LINE1:memory_average#0000FF:Memory Avg"
  end
  
  it "should store definition and printable for area" do
    result = @graph.area RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory Avg"
    result[0].should == "DEF:memory_average=#{RRD_FILE}:memory:AVERAGE"
    result[1].should == "AREA:memory_average#0000FF:Memory Avg"
  end
  
  it "should create a graph correctly" do
    @graph.line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory Avg"
    RRD::Wrapper.should_receive(:graph).with(IMG_FILE,
                                            "--full-size-mode",
                                            "--end", anything(),
                                            "--height", "200",
                                            "--start", anything(),
                                            "--title", "Title",
                                            "--width", "800",
                                            "DEF:memory_average=#{RRD_FILE}:memory:AVERAGE",
                                            "LINE1:memory_average#0000FF:Memory Avg").and_return true
    @graph.save
  end
  
end