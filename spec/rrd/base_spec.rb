require "spec_helper"

describe RRD::Base do

  before do
    @rrd = RRD::Base.new(RRD_FILE)
  end

  it "creates a rrd file using dsl" do
    expect(File).not_to be_file(RRD_FILE)

    @rrd.create :start => Time.now - 10.seconds, :step => 5.minutes do
      datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
      archive :average, :every => 10.minutes, :during => 1.year
    end

    expect(File).to be_file(RRD_FILE)
  end

  it "creates a rrd file using create!" do
    expect(File).not_to be_file(RRD_FILE)

    @rrd.create! :start => Time.now - 10.seconds, :step => 5.minutes do
      datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
      archive :average, :every => 10.minutes, :during => 1.year
    end

    expect(File).to be_file(RRD_FILE)
  end

  it "updates the rrd file with data" do
    time = Time.now
    # one datum for every datasource, ordered
    data = [20, 20.0, nil]
    update_data = "#{time.to_i}:20:20.0:U"
    expect(RRD::Wrapper).to receive(:update).with(RRD_FILE, update_data).and_return(true)
    expect(@rrd.update(time, *data)).to be_truthy
  end

  it "fetches data from rrd file" do
    start_time = Time.now - 3600
    end_time = Time.now
    raw_params = ["AVERAGE", "--start", "#{start_time.to_i}", "--end", "#{end_time.to_i}", "--resolution", "1" ]
    expect(RRD::Wrapper).to receive(:fetch).with(RRD_FILE, raw_params[0], anything, anything, anything, anything, anything, anything).and_return([])
    @rrd.fetch(:average, :start => start_time, :end => end_time, :resolution => 1.second)
  end

  it "returns the rrd file information" do
    info = {"filename" => RRD_FILE}
    expect(RRD::Wrapper).to receive(:info).with(RRD_FILE).and_return(info)
    expect(@rrd.info).to  equal(info)
  end

  it "restores a rrd from xml" do
    expect(RRD::Wrapper).to receive(:restore).with(XML_FILE, RRD_FILE, "--force-overwrite").and_return(true)
    expect(@rrd.restore(XML_FILE, :force_overwrite => true)).to be_truthy
  end

  it "resizes a RRA from rrd file" do
    expect(RRD::Wrapper).to receive(:info).and_return({"step" => 5, "rra[1].pdp_per_row" => 12}) # step of 1 minute on RRA
    expect(RRD::Wrapper).to receive(:resize).with(RRD_FILE, "1", "GROW", "60").and_return(true)
    @rrd.resize(1, :grow => 1.hour)
  end

  it "returns the last update made" do
    expect(RRD::Wrapper).to receive(:last_update).with(RRD_FILE).and_return([])
    @rrd.last_update
  end

  it "dumps the binary rrd to xml" do
    xml_file = "new_xml"
    expect(RRD::Wrapper).to receive(:dump).with(RRD_FILE, xml_file, "--no-header").and_return(true)
    expect(@rrd.dump(xml_file, :no_header => true)).to be_truthy
  end

  it "returns the starting date" do
    expect(RRD::Wrapper).to receive(:first).with(RRD_FILE).and_return(Time.now.to_i)
    expect(@rrd.starts_at).to be_a(Time)
  end

  it "returns the ending date" do
    expect(RRD::Wrapper).to receive(:last).with(RRD_FILE).and_return(Time.now.to_i)
    expect(@rrd.ends_at).to be_a(Time)
  end

  it "returns the error" do
    expect(@rrd.error).to be_empty
    expect(@rrd.restore("unknown file")).to be_falsey
    expect(@rrd.error).not_to be_empty
  end

  it "has an alias to starts_at as first" do
    expect(RRD::Wrapper).to receive(:first).twice.with(RRD_FILE).and_return(Time.now.to_i)
    expect(@rrd.first).to eq(@rrd.starts_at)
  end

  it "has an alias to ends_at as last" do
    expect(RRD::Wrapper).to receive(:last).twice.with(RRD_FILE).and_return(Time.now.to_i)
    expect(@rrd.last).to eq(@rrd.ends_at)
  end

  context "when using bang methods" do
    it "has the normal method" do
      RRD::Base::BANG_METHODS.each do |bang_method|
        method = bang_method.to_s.match(/^(.+)!$/)[1]
        expect(@rrd.respond_to?(method)).to be_truthy
      end
    end

    it "lists them" do
      expect(@rrd.methods.sort & RRD::Base::BANG_METHODS.sort).to eq(RRD::Base::BANG_METHODS.sort)
    end

    it "returns the normal method result" do
      expect(@rrd.restore!(XML_FILE)).to be_truthy
    end

    it "raises error if the normal method is not bangable" do
      expect(@rrd).not_to receive(:bang)
      expect { @rrd.error! }.to raise_error(NoMethodError)
    end

    it "expects { $1 }.to raise error if the normal method result is false" do
      expect(@rrd).to receive(:info).and_return(false)
      expect(@rrd).to receive(:error).and_return("error message")
      expect { @rrd.bang(:info) }.to raise_error("error message")
    end
  end
end
