require "spec_helper"
require 'digest/md5'

describe RRD::Xport do
    
  before do
    @rrd = RRD::Base.new(RRD_FILE)
    @rrd.restore(XML_FILE)

    @xport = RRD::Xport.new :start => @rrd.starts_at, :end => @rrd.ends_at, :step => 2
  end
  
  it "should store definition for rrd data" do
    result = @xport.for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE
    result.should == "DEF:cpu0=#{RRD_FILE}:cpu0:AVERAGE"
  end

  it "should store definition for calculated data" do
    result = @xport.using_calculated_data "half_mem", :calc => "mem,2,/"
    result.should == "CDEF:half_mem=mem,2,/"
  end
    
  it "should store printable for xport" do
    result = @xport.xport 'memory', :label => "Memory"
    result[0].should == "XPORT:memory:Memory"
  end
  
  it "should export data correctly" do
    memory_ds_name = Digest::MD5.hexdigest("#{RRD_FILE}_memory_average")
    cpu_ds_name = Digest::MD5.hexdigest("#{RRD_FILE}_cpu0_average")
    expected_args = [
      "--start", @rrd.starts_at.to_i.to_s,
      "--end", @rrd.ends_at.to_i.to_s,    
      "--step", "2",  
      "DEF:memory=/Users/neilljordan/Documents/rrd-ffi/spec/vm.rrd:memory:AVERAGE",
      "DEF:cpu0=#{RRD_FILE}:cpu0:AVERAGE",      
      "CDEF:half_mem=memory,2,/",            
      "XPORT:memory:Memory\\: Average",
      "XPORT:cpu0:cpu0\\: Average",                    
      "XPORT:half_mem:Half Memory",                    
    ]

    @xport.for_rrd_data "memory", :memory => :average, :from => RRD_FILE
    @xport.for_rrd_data "cpu0", :cpu0 => :average, :from => RRD_FILE
    @xport.using_calculated_data "half_mem", :calc => "memory,2,/"
    @xport.xport "memory", :label => "Memory: Average"
    @xport.xport "cpu0", :label => "cpu0: Average"
    @xport.xport "half_mem", :label => "Half Memory"

    generated_args = @xport.send(:generate_args)
    generated_args.should == expected_args

    data = @xport.save

    expected_data = [
      ["time", "Memory: Average", "cpu0: Average", "Half Memory"],
      [1266944780, 536870912.0, 0.0002, 268435456.0],
      [1266944785, 536870912.0, 0.0022, 268435456.0],
      [1266944790, 536870912.0, 0.0022, 268435456.0],
    ]

    data[0,4].should == expected_data
  end

  it "should export via dsl" do

  end

end