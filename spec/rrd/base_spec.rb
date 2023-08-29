require "spec_helper"

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

  it "should create a rrd file using create!" do
    File.should_not be_file(RRD_FILE)

    @rrd.create! :start => Time.now - 10.seconds, :step => 5.minutes do
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
    @rrd.update(time, *data).should be_truthy
  end

  it "should fetch data from rrd file" do
    start_time = Time.now - 3600
    end_time = Time.now
    raw_params = ["AVERAGE", "--start", "#{start_time.to_i}", "--end", "#{end_time.to_i}", "--resolution", "1" ]
    RRD::Wrapper.should_receive(:fetch).with(RRD_FILE, raw_params[0], anything, anything, anything, anything, anything, anything).and_return([])
    @rrd.fetch(:average, :start => start_time, :end => end_time, :resolution => 1.second)
  end

  it "should return the rrd file information" do
    info = {"filename" => RRD_FILE}
    RRD::Wrapper.should_receive(:info).with(RRD_FILE).and_return(info)
    @rrd.info.should == info
  end

  it "should restore a rrd from xml" do
    RRD::Wrapper.should_receive(:restore).with(XML_FILE, RRD_FILE, "--force-overwrite").and_return(true)
    @rrd.restore(XML_FILE, :force_overwrite => true).should be_truthy
  end

  it "should resize a RRA from rrd file" do
    RRD::Wrapper.should_receive(:info).and_return({"step" => 5, "rra[1].pdp_per_row" => 12}) # step of 1 minute on RRA
    RRD::Wrapper.should_receive(:resize).with(RRD_FILE, "1", "GROW", "60").and_return(true)
    @rrd.resize(1, :grow => 1.hour)
  end

  it "should return the last update made" do
    RRD::Wrapper.should_receive(:last_update).with(RRD_FILE).and_return([])
    @rrd.last_update
  end

  it "should dump the binary rrd to xml" do
    xml_file = "new_xml"
    RRD::Wrapper.should_receive(:dump).with(RRD_FILE, xml_file, "--no-header").and_return(true)
    @rrd.dump(xml_file, :no_header => true).should be_truthy
  end

  it "should return the starting date" do
    RRD::Wrapper.should_receive(:first).with(RRD_FILE).and_return(Time.now.to_i)
    @rrd.starts_at.should be_a(Time)
  end

  it "should return the ending date" do
    RRD::Wrapper.should_receive(:last).with(RRD_FILE).and_return(Time.now.to_i)
    @rrd.ends_at.should be_a(Time)
  end

  it "should return the error" do
    @rrd.error.should be_empty
    @rrd.restore("unknown file").should be_falsey
    @rrd.error.should_not be_empty
  end

  it "should have an alias to starts_at as first" do
    RRD::Wrapper.should_receive(:first).twice.with(RRD_FILE).and_return(Time.now.to_i)
    @rrd.first.should == @rrd.starts_at
  end

  it "should have an alias to ends_at as last" do
    RRD::Wrapper.should_receive(:last).twice.with(RRD_FILE).and_return(Time.now.to_i)
    @rrd.last.should == @rrd.ends_at
  end

  context "when using bang methods" do
    it "should have the normal method" do
      RRD::Base::BANG_METHODS.each do |bang_method|
        method = bang_method.to_s.match(/^(.+)!$/)[1]
        @rrd.respond_to?(method).should be_truthy
      end
    end

    it "should list them" do
      (@rrd.methods & RRD::Base::BANG_METHODS).should == RRD::Base::BANG_METHODS
    end

    it "should return the normal method result" do
      @rrd.restore!(XML_FILE).should be_truthy
    end

    it "should raise error if the normal method is not bangable" do
      @rrd.should_not_receive(:bang)
      lambda{@rrd.error!}.should raise_error(NoMethodError)
    end

    it "should raise error if the normal method result is false" do
      @rrd.should_receive(:info).and_return(false)
      @rrd.should_receive(:error).and_return("error message")
      lambda{@rrd.bang(:info)}.should raise_error("error message")
    end
  end
end
