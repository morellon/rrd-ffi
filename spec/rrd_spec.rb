require File.dirname(__FILE__) + "/spec_helper"

describe RRD do
  
  before do
    RRD::Base.new(RRD_FILE).restore(XML_FILE)
  end
  
  it "should create a graph using simple DSL" do
    result = RRD.graph IMG_FILE, :title => "Test", :width => 800, :height => 250 do
      area RRD_FILE, :cpu0 => :average, :color => "#00FF00", :label => "CPU 0"
      line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory"
    end
    
    result.should be_true
    File.should be_file(IMG_FILE)
  end
  
  xit "should create a graph using advanced DSL" do
    result = RRD.graph IMG_FILE, :title => "Test", :width => 800, :height => 250, :start => "-1d", :end => "n" do
      for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE
      for_rrd_data "mem", :memory => :average, :from => RRD_FILE, :start => "-1d", :end => "n", :shift => 3600
      using_calculated_data "half_mem", :calc => "mem,2,/"
      using_value "mem_avg", :calc => "mem,AVERAGE"
      draw_line :data => "mem", :color => "#0000FF", :label => "Memory", :width => 1
      draw_area :data => "cpu", :color => "#00FF00", :label => "CPU 0"
      print_comment "Information: "
      print_value "mem_avg", :format => "%6.2lf %SB"
    end
    
    result.should be_true
    File.should be_file(IMG_FILE)
  end
end