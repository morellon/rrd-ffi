require "spec_helper"

describe RRD::Wrapper do
  context "when looking for librrd path" do
    before :each do
      Object.send(:remove_const, :RRD_LIB) if defined?(::RRD_LIB)
      ENV["RRD_LIB"] = nil
    end

    it "looks on RRD_LIB constant first" do
      ::RRD_LIB = "first"
      ENV["RRD_LIB"] = "second"
      expect(RRD::Wrapper.detect_rrd_lib).to eq "first"
    end

    it "looks on ENV if RRD_LIB is not defined" do
      ENV["RRD_LIB"] = "second"
      expect(RRD::Wrapper.detect_rrd_lib).to eq "second"
    end

    it "return 'rrd' for FFI to look up if can't use RRD_LIB or ENV" do
      expect(RRD::Wrapper.detect_rrd_lib).to eq "rrd"
    end
  end

  context "when no rrd file exists" do
    it "restores a rrd from xml" do
      expect(RRD::Wrapper.restore(XML_FILE, RRD_FILE)).to be_truthy
    end

    it "creates a rrd" do
      expect(RRD::Wrapper.create(RRD_FILE,
                          "--step", "300",
                          "DS:ifOutOctets:COUNTER:1800:0:4294967295",
                          "RRA:AVERAGE:0.5:1:2016")).to be_truthy
      expect(File).to be_file(RRD_FILE)
    end
  end

  context "when there is a rrd file" do
    before do
      RRD::Wrapper.clear_error
      RRD::Wrapper.restore(XML_FILE, RRD_FILE)
    end

    it "updates the rrd file" do
      expect(RRD::Wrapper.update(RRD_FILE, "N:500000000:U:U:U:U:U:U:U:U")).to be_truthy
    end

    it "fetches values" do
      values = RRD::Wrapper.fetch(RRD_FILE, "AVERAGE", "--start", "1266933600", "--end", "1267020000")
      expect(values.size).to eq `rrdtool fetch #{RRD_FILE} AVERAGE --start 1266933600 --end 1267020000 | wc -l`.to_i - 1
    end

    it 'xports values' do
      values = RRD::Wrapper.xport("--start", "1266933600", "--end", "1266944400", "DEF:xx=#{RRD_FILE}:cpu0:AVERAGE", "XPORT:xx:Legend 0")
      expect(values).to eq [["time", "Legend 0"], [1266933600, 0.0008], [1266937200, 0.0008], [1266940800, 0.0008]]
    end

    it "returns info data about this file" do
      info = RRD::Wrapper.info(RRD_FILE)
      expect(info["filename"]).to eq RRD_FILE
    end

    it "returns the first entered date" do
      expect(RRD::Wrapper.first(RRD_FILE)).to eq `rrdtool first #{RRD_FILE}`.chomp.to_i
    end

    it "returns the last entered date" do
      expect(RRD::Wrapper.last(RRD_FILE)).to eq `rrdtool last #{RRD_FILE}`.chomp.to_i
    end

    it "returns the last entered values" do
      pending unless RRD::Wrapper.respond_to?(:rrd_lastupdate_r)
      result = RRD::Wrapper.last_update(RRD_FILE)
      expect(result.size).to eq(2)
      expect(`rrdtool lastupdate spec/vm.rrd`).to include(result[1][0].to_s)
    end

    it "creates a graph correctly" do
      RRD::Wrapper.graph(IMG_FILE, "--width", "1000", "--height", "300", "DEF:data=#{RRD_FILE}:memory:AVERAGE", "LINE1:data#0000FF:Memory Avg", "--full-size-mode")
      expect(File).to be_file(IMG_FILE)
    end

    it "tunes rrd" do
      expect(RRD::Wrapper.tune(RRD_FILE, "--minimum", "memory:5")).to be_truthy
    end

    it "resizes rrd" do
      expect(RRD::Wrapper.resize(RRD_FILE, "0", "GROW", "10")).to be_truthy
    end

    it "dumps rrd binary to xml" do
      new_xml = XML_FILE+"new"
      FileUtils.rm new_xml rescue nil

      expect(RRD::Wrapper.dump(RRD_FILE, new_xml)).to be_truthy
      expect(File).to be_file(new_xml)

      FileUtils.rm new_xml rescue nil
    end

    it "returns the error correctly, cleaning the error var" do
      expect(RRD::Wrapper.error).to be_empty
      expect(RRD::Wrapper.info("error")).to be_falsey
      expect(RRD::Wrapper.error).not_to be_empty
    end
  end

  context "when using bang methods" do

    it "responds to them" do
      RRD::Wrapper::BANG_METHODS.each do |method|
        expect(RRD::Wrapper.respond_to?(method)).to be_truthy
      end
    end

    it "has the normal method" do
      RRD::Wrapper::BANG_METHODS.each do |bang_method|
        method = bang_method.to_s.match(/^(.+)!$/)[1]
        expect(RRD::Wrapper.respond_to?(method)).to be_truthy
      end
    end

    it "lists them" do
      expect(RRD::Wrapper.methods.sort & RRD::Wrapper::BANG_METHODS.sort).to eq RRD::Wrapper::BANG_METHODS
    end

    it "returns the normal method result" do
      expect(RRD::Wrapper.restore!(XML_FILE, RRD_FILE)).to be_truthy
    end

    it "raises error if the normal method is not bangable" do
      expect(RRD::Wrapper).not_to receive(:bang)
      expect { RRD::Wrapper.error! }.to raise_error(NoMethodError)
    end

    it "raises error if the normal method result is false" do
      expect(RRD::Wrapper).to receive(:info).and_return(false)
      expect(RRD::Wrapper).to receive(:error).and_return("error message")
      expect { RRD::Wrapper.bang(:info) }.to raise_error("error message")
    end
  end

  def memory_leak(many=30)
    2.times {GC.start}
    starting_memory = 0
    begin
      many.times {yield}
    end
    2.times {GC.start}
    ending_memory = 0
    ending_memory - starting_memory == starting_memory * 0.2
  end
end
