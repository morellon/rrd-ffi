require "spec_helper"

describe RRD::Graph do
    
  before do
    RRD::Base.new(RRD_FILE).restore(XML_FILE)
    @graph = RRD::Graph.new IMG_FILE, :title => "Title", :width => 800, :height => 200, :full_size_mode => true,
                            :color => ["FONT#000000", "BACK#FFFFFF"]
  end
  
  it "should store definition for rrd data" do
    result = @graph.for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE
    result.should == "DEF:cpu0=#{RRD_FILE}:cpu0:AVERAGE"
  end

  it "should store definition for rrd data with extended options" do
    start_at = Time.now - 2.day
    end_at   = Time.now - 1.day
    step     = 60
    result = @graph.for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE, :start => start_at, :end => end_at, :step => step
    result.should == "DEF:cpu0=#{RRD_FILE}:cpu0:AVERAGE:step=#{step}:start=#{start_at.to_i}:end=#{end_at.to_i}"
  end

  it "should store definition for calculated data" do
    result = @graph.using_calculated_data "half_mem", :calc => "mem,2,/"
    result.should == "CDEF:half_mem=mem,2,/"
  end
  
  it "should store definition for static value" do
    result = @graph.using_value "mem_avg", :calc => "mem,AVERAGE"
    result.should == "VDEF:mem_avg=mem,AVERAGE"
  end

  it "should store definition for offset data" do
    result = @graph.shift :cpu0 => Time.now - 2.day
  end
  
  it "should store printable for line drawing" do
    result = @graph.draw_line :data => "mem", :color => "#0000FF", :label => "Memory", :width => 1
    result.should == "LINE1:mem#0000FF:Memory"
  end
  
  it "should store printable for line drawing without label" do
    result = @graph.draw_line :data => "mem", :color => "#0000FF", :width => 1
    result.should == "LINE1:mem#0000FF"
  end
  
  it "should store printable for line drawing with extra" do
    result = @graph.draw_line :data => "mem", :color => "#0000FF", :label => "Memory", :width => 1, :extra => "dashes=15,10,10,15"
    result.should == "LINE1:mem#0000FF:Memory:dashes=15,10,10,15"
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
    result = @graph.line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory: Avg"
    result[0].should == "DEF:memory_average=#{RRD_FILE}:memory:AVERAGE"
    result[1].should == "LINE1:memory_average#0000FF:Memory\\: Avg"
  end

  it "should store definition and printable for line (without label)" do
    result = @graph.line RRD_FILE, :memory => :average, :color => "#0000FF"
    result[0].should == "DEF:memory_average=#{RRD_FILE}:memory:AVERAGE"
    result[1].should == "LINE1:memory_average#0000FF"
  end
  
  it "should store definition and printable for area" do
    result = @graph.area RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory: Avg"
    result[0].should == "DEF:memory_average=#{RRD_FILE}:memory:AVERAGE"
    result[1].should == "AREA:memory_average#0000FF:Memory\\: Avg"
  end
  
  it "should create a graph correctly" do
    expected_args = [IMG_FILE,
                    "--full-size-mode",
                    "--color", "FONT#000000",
                    "--color", "BACK#FFFFFF",
                    "--title", "Title",
                    "--start", #starting_time,
                    "--height", "200",
                    "--end", #ending_time,
                    "--width", "800",
                    "DEF:memory_average=#{RRD_FILE}:memory:AVERAGE",
                    "LINE1:memory_average#0000FF:Memory\\: Avg"]
    @graph.line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory: Avg"
    generated_args = @graph.send(:generate_args)
    generated_args.size.should == expected_args.size + 2
    generated_args.first.should == expected_args.first
    (expected_args - generated_args).should be_empty
  end

  
end