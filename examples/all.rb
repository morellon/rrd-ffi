require "rubygems"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require "rrd"

RRD_FILE = File.expand_path(File.dirname(__FILE__) + "/../spec/vm.rrd")
RESIZE_FILE = File.expand_path(File.dirname(__FILE__) + "/resize.rrd")
XML_FILE = File.expand_path(File.dirname(__FILE__) + "/../spec/vm.xml")
IMG_FILE = File.expand_path(File.dirname(__FILE__) + "/../spec/vm.png")

i = 1
while TRUE
  rrd = RRD::Base.new(RRD_FILE)
  rrd.restore!(XML_FILE, :force_overwrite => true)
  # rrd.first! # OK
  # rrd.last! # OK
  # rrd.last_update! # average leak
  # rrd.update!(Time.now, nil, nil, nil, nil, nil, nil, nil, nil, nil) # OK
  # rrd.fetch! :average # low leak
  # rrd.info! # OK
  # rrd.resize!(1, :grow => 1.hour) # low leak
  #    
  # RRD::Wrapper.tune!(RRD_FILE, "--minimum", "memory:5") # OK
  #  
  # new_rrd = RRD::Base.new(RRD_FILE+".new")
  # new_rrd.create! :start => Time.now - 10.seconds, :step => 5.minutes do
  #   datasource "memory", :type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited
  #   archive :average, :every => 10.minutes, :during => 1.year
  # end # OK
  # new_rrd.dump!(XML_FILE+".new") # OK
  # 
  RRD.graph! IMG_FILE, :title => "Test", :width => 800, :height => 250 do
    area RRD_FILE, :cpu0 => :average, :color => "#00FF00", :label => "CPU: 0"
    line RRD_FILE, :memory => :average, :color => "#0000FF", :label => "Memory"
  end # average leak
  
  FileUtils.rm new_rrd.rrd_file rescue nil
  FileUtils.rm RESIZE_FILE rescue nil
  FileUtils.rm RRD_FILE rescue nil
  FileUtils.rm XML_FILE+".new" rescue nil
  
  GC.start
  memory_usage = `ps -o rss= -p #{Process.pid}`.to_i
  initial_memory ||= memory_usage
  puts "##{i} Mem: #{memory_usage-initial_memory} from #{initial_memory}"
  i += 1
end
  