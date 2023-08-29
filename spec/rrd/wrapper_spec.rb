require "spec_helper"

describe RRD::Wrapper do
  context "when looking for librrd path" do
    before :each do
      Object.send(:remove_const, :RRD_LIB) if defined?(::RRD_LIB)
      ENV["RRD_LIB"] = nil
    end

    it "should look on RRD_LIB constant first" do
      ::RRD_LIB = "first"
      ENV["RRD_LIB"] = "second"
      RRD::Wrapper.detect_rrd_lib.should == "first"
    end

    it "should look on ENV if RRD_LIB is not defined" do
      ENV["RRD_LIB"] = "second"
      RRD::Wrapper.detect_rrd_lib.should == "second"
    end

    it "should return 'rrd' for FFI to look up if can't use RRD_LIB or ENV" do
      RRD::Wrapper.detect_rrd_lib.should == "rrd"
    end
  end

  context "when no rrd file exists" do

    it "should restore a rrd from xml" do
      RRD::Wrapper.restore(XML_FILE, RRD_FILE).should be_truthy
    end

    it "should create a rrd" do
      RRD::Wrapper.create(RRD_FILE,
                          "--step", "300",
                          "DS:ifOutOctets:COUNTER:1800:0:4294967295",
                          "RRA:AVERAGE:0.5:1:2016").should be_truthy
      File.should be_file(RRD_FILE)
    end
  end

  context "when there is a rrd file" do
    before do
      RRD::Wrapper.clear_error
      RRD::Wrapper.restore(XML_FILE, RRD_FILE)
    end

    it "should update the rrd file" do
      RRD::Wrapper.update(RRD_FILE, "N:500000000:U:U:U:U:U:U:U:U").should be_truthy
    end

    it "should fetch values" do
      values = RRD::Wrapper.fetch(RRD_FILE, "AVERAGE", "--start", "1266933600", "--end", "1267020000")
      values.size.should == `rrdtool fetch #{RRD_FILE} AVERAGE --start 1266933600 --end 1267020000 | wc -l`.to_i - 1
    end

    it 'should xport values' do
      values = RRD::Wrapper.xport("--start", "1266933600", "--end", "1266944400", "DEF:xx=#{RRD_FILE}:cpu0:AVERAGE", "XPORT:xx:Legend 0")
      values.should == [["time", "Legend 0"], [1266933600, 0.0008], [1266937200, 0.0008], [1266940800, 0.0008]]
    end

    it "should return info data about this file" do
      info = RRD::Wrapper.info(RRD_FILE)
      info["filename"].should == RRD_FILE
    end

    it "should return the first entered date" do
      RRD::Wrapper.first(RRD_FILE).should == `rrdtool first #{RRD_FILE}`.chomp.to_i
    end

    it "should return the last entered date" do
      RRD::Wrapper.last(RRD_FILE).should == `rrdtool last #{RRD_FILE}`.chomp.to_i
    end

    it "should return the last entered values" do
      pending unless RRD::Wrapper.respond_to?(:rrd_lastupdate_r)
      result = RRD::Wrapper.last_update(RRD_FILE)
      expect(result.size).to eq(2)
      `rrdtool lastupdate spec/vm.rrd`.should include(result[1][0].to_s)
    end

    it "should create a graph correctly" do
      RRD::Wrapper.graph(IMG_FILE, "--width", "1000", "--height", "300", "DEF:data=#{RRD_FILE}:memory:AVERAGE", "LINE1:data#0000FF:Memory Avg", "--full-size-mode")
      File.should be_file(IMG_FILE)
    end

    it "should tune rrd" do
      RRD::Wrapper.tune(RRD_FILE, "--minimum", "memory:5").should be_truthy
    end

    it "should resize rrd" do
      RRD::Wrapper.resize(RRD_FILE, "0", "GROW", "10").should be_truthy
    end

    it "should dump rrd binary to xml" do
      new_xml = XML_FILE+"new"
      FileUtils.rm new_xml rescue nil

      RRD::Wrapper.dump(RRD_FILE, new_xml).should be_truthy
      File.should be_file(new_xml)

      FileUtils.rm new_xml rescue nil
    end

    it "should return the error correctly, cleaning the error var" do
      RRD::Wrapper.error.should be_empty
      RRD::Wrapper.info("error").should be_falsey
      RRD::Wrapper.error.should_not be_empty
    end
  end

  context "when using bang methods" do

    it "should respond to them" do
      RRD::Wrapper::BANG_METHODS.each do |method|
        RRD::Wrapper.respond_to?(method).should be_truthy
      end
    end

    it "should have the normal method" do
      RRD::Wrapper::BANG_METHODS.each do |bang_method|
        method = bang_method.to_s.match(/^(.+)!$/)[1]
        RRD::Wrapper.respond_to?(method).should be_truthy
      end
    end

    it "should list them" do
      (RRD::Wrapper.methods.sort & RRD::Wrapper::BANG_METHODS.sort)
        .should == RRD::Wrapper::BANG_METHODS
    end

    it "should return the normal method result" do
      RRD::Wrapper.restore!(XML_FILE, RRD_FILE).should be_truthy
    end

    it "should raise error if the normal method is not bangable" do
      RRD::Wrapper.should_not_receive(:bang)
      lambda{RRD::Wrapper.error!}.should raise_error(NoMethodError)
    end

    it "should raise error if the normal method result is false" do
      RRD::Wrapper.should_receive(:info).and_return(false)
      RRD::Wrapper.should_receive(:error).and_return("error message")
      lambda{RRD::Wrapper.bang(:info)}.should raise_error("error message")
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
