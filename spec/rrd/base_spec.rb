require File.dirname(__FILE__) + "/../spec_helper"

describe RRD::Base do
  
  before do
    @rrd = RRD::Base.new(RRD_FILE)
  end
  
  it "should create a rrd file using dsl" do
    File.should_not be_file(RRD_FILE)
    
    @rrd.create :start => Time.now - 10.seconds, :step => 5.minutes do
      datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
      archive :average, :every => 10.minutes, :during => 1.year
    end
    
    File.should be_file(RRD_FILE)
  end
  
  it "should update the rrd file with data" do
    time = Time.now
    # one datum for every datasource, ordered
    data = [20, 20.0, nil]
    update_data = "#{time.to_i}:20:20.0:U"
    RRD::Wrapper.should_receive(:update).with(RRD_FILE, update_data).and_return(true)
    @rrd.update(time, *data).should be_true
  end
  
  it "should fetch data from rrd file" do
    start_time = Time.now - 3600
    end_time = Time.now
    raw_params = ["AVERAGE", "--end", "#{end_time.to_i}", "--resolution", "1", "--start", "#{start_time.to_i}"]
    RRD::Wrapper.should_receive(:fetch).with(RRD_FILE, *raw_params).and_return([])
    @rrd.fetch(:average, :start => start_time, :end => end_time, :resolution => 1.second)
  end
  
  it "should return the rrd file information" do
    info = {"filename" => RRD_FILE}
    RRD::Wrapper.should_receive(:info).with(RRD_FILE).and_return(info)
    @rrd.info.should == info
  end
  
  it "should restore a rrd from xml" do
    RRD::Wrapper.should_receive(:restore).with(XML_FILE, RRD_FILE).and_return(true)
    @rrd.restore(XML_FILE).should be_true
  end
  
  it "should return the starting date" do
    RRD::Wrapper.should_receive(:first).with(RRD_FILE).and_return(Time.now.to_i)
    @rrd.starts_at.should be_a(Time)
  end
  
  it "should return the ending date" do
    RRD::Wrapper.should_receive(:last).with(RRD_FILE).and_return(Time.now.to_i)
    @rrd.ends_at.should be_a(Time)
  end
  
  it "should respond to first"
  it "should respond to last"
end