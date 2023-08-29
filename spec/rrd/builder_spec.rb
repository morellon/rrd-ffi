require "spec_helper"

describe RRD::Builder do

  before do
    @start_time = Time.now - 10.seconds
    @builder = RRD::Builder.new "file.rrd", :start => @start_time
  end

  it "should store a datasource" do
    datasource = @builder.datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
    datasource.should == "DS:memory:GAUGE:600:0:U"
  end

  it "should store an archive" do
    archive = @builder.archive :average, :every => 10.minutes, :during => 1.day
    archive.should == "RRA:AVERAGE:0.5:2:144"
  end

  it "should create rrd file" do
    @builder.datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
    @builder.archive :average, :every => 10.minutes, :during => 1.day
    RRD::Wrapper.should_receive(:create).with("file.rrd",
                                              "--start", @start_time.to_i.to_s,
                                              "--step", "300",
                                              "DS:memory:GAUGE:600:0:U",
                                              "RRA:AVERAGE:0.5:2:144")
    @builder.save
  end
end
