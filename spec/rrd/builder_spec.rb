require "spec_helper"

describe RRD::Builder do

  before do
    @start_time = Time.now - 10.seconds
    @builder = RRD::Builder.new "file.rrd", :start => @start_time
  end

  it "stores a datasource" do
    datasource = @builder.datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
    expect(datasource).to eq "DS:memory:GAUGE:600:0:U"
  end

  it "stores an archive" do
    archive = @builder.archive :average, :every => 10.minutes, :during => 1.day
    expect(archive).to eq "RRA:AVERAGE:0.5:2:144"
  end

  it "creates rrd file" do
    @builder.datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
    @builder.archive :average, :every => 10.minutes, :during => 1.day
    expect(RRD::Wrapper).to receive(:create).with(
      "file.rrd",
      "--step", "300",
      "--start", @start_time.to_i.to_s,
      "DS:memory:GAUGE:600:0:U",
      "RRA:AVERAGE:0.5:2:144")
    @builder.save
  end
end
