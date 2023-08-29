require "spec_helper"

describe RRD do

  before do
    RRD::Base.new(RRD_FILE).restore(XML_FILE)
  end

  it "should create a graph using simple DSL" do
    result = RRD.graph IMG_FILE, :title => "Test", :width => 800, :height => 250 do
      area RRD_FILE, :cpu0 => :average, :color => "#00FF00", :label => "CPU: 0"
      line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory"
    end

    result.should be_true
    File.should be_file(IMG_FILE)
  end

  it "should create a graph using graph!" do
    result = RRD.graph! IMG_FILE, :title => "Test", :width => 800, :height => 250 do
      area RRD_FILE, :cpu0 => :average, :color => "#00FF00", :label => "CPU: 0"
      line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory"
    end

    result.should be_true
    File.should be_file(IMG_FILE)
  end

  it "should list all bang methods" do
    (RRD.methods & RRD::BANG_METHODS).should == RRD::BANG_METHODS
  end

  it "should create a graph using advanced DSL" do
    result = RRD.graph IMG_FILE, :title => "Test", :width => 800, :height => 250, :start => Time.now - 1.day, :end => Time.now do
      for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE
      for_rrd_data "mem", :memory => :average, :from => RRD_FILE #TODO: :start => Time.now - 1.day, :end => Time.now, :shift => 1.hour
      using_calculated_data "half_mem", :calc => "mem,2,/"
      using_value "mem_avg", :calc => "mem,AVERAGE"
      draw_line :data => "mem", :color => "#0000FF", :label => "Memory: Average", :width => 1, :extra => "dashes"
      draw_area :data => "cpu0", :color => "#00FF00", :label => "CPU 0"
      print_comment "Information - "
      print_value "mem_avg", :format => "%6.2lf %SB"
    end

    result.should be_truthy
    File.should be_file(IMG_FILE)
  end

  it "should export data using xport dsl" do
    rrd = RRD::Base.new(RRD_FILE)
    data = RRD.xport :start => rrd.starts_at, :end => rrd.ends_at, :step => 2 do
      for_rrd_data "memory", :memory => :average, :from => RRD_FILE
      for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE
      using_calculated_data "half_mem", :calc => "memory,2,/"
      xport "memory", :label => "Memory: Average"
      xport "cpu0", :label => "cpu0: Average"
      xport "half_mem", :label => "Half Memory"
    end

    expected_data = [
      ["time", "Memory: Average", "cpu0: Average", "Half Memory"],
      [1266944780, 536870912.0, 0.0002, 268435456.0],
      [1266944785, 536870912.0, 0.0022, 268435456.0],
      [1266944790, 536870912.0, 0.0022, 268435456.0],
    ]

    data[0,4].should == expected_data
  end

  it "should export data using xport!" do
    rrd = RRD::Base.new(RRD_FILE)
    data = RRD.xport! :start => rrd.starts_at, :end => rrd.ends_at, :step => 2 do
      for_rrd_data "memory", :memory => :average, :from => RRD_FILE
      for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE
      using_calculated_data "half_mem", :calc => "memory,2,/"
      xport "memory", :label => "Memory: Average"
      xport "cpu0", :label => "cpu0: Average"
      xport "half_mem", :label => "Half Memory"
    end

    expected_data = [
      ["time", "Memory: Average", "cpu0: Average", "Half Memory"],
      [1266944780, 536870912.0, 0.0002, 268435456.0],
      [1266944785, 536870912.0, 0.0022, 268435456.0],
      [1266944790, 536870912.0, 0.0022, 268435456.0],
    ]

    data[0,4].should == expected_data
  end
end
