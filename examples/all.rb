require "rubygems"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require "rrd"

RRD_FILE = File.expand_path(File.dirname(__FILE__) + "/../spec/vm.rrd")
RESIZE_FILE = File.expand_path(File.dirname(__FILE__) + "/resize.rrd")
XML_FILE = File.expand_path(File.dirname(__FILE__) + "/../spec/vm.xml")
IMG_FILE = File.expand_path(File.dirname(__FILE__) + "/../spec/vm.png")

while TRUE
  rrd = RRD::Base.new(RRD_FILE)
  rrd.restore!(XML_FILE, :force_overwrite => true)
  rrd.first!
  rrd.last!
  rrd.last_update!
  rrd.update!(Time.now, nil, nil, nil, nil, nil, nil, nil, nil, nil)
  rrd.fetch! :average
  rrd.info!
  rrd.resize!(1, :grow => 1.hour)
  
  RRD::Wrapper.tune!(RRD_FILE, "--minimum", "memory:5")
  
  new_rrd = RRD::Base.new(RRD_FILE+".new")
  new_rrd.create! :start => Time.now - 10.seconds, :step => 5.minutes do
    datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
    archive :average, :every => 10.minutes, :during => 1.year
  end
  
  RRD.graph! IMG_FILE, :title => "Test", :width => 800, :height => 250 do
    area RRD_FILE, :cpu0 => :average, :color => "#00FF00", :label => "CPU: 0"
    line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory"
  end
  
  FileUtils.rm new_rrd.rrd_file rescue nil
  FileUtils.rm RESIZE_FILE rescue nil
  
  sleep(0.1)
end
  