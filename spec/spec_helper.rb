require "rubygems"
require "rspec"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require "rrd"

$VERBOSE = nil
RRD_FILE = File.expand_path(File.dirname(__FILE__) + "/vm.rrd")
IMG_FILE = File.expand_path(File.dirname(__FILE__) + "/vm.png")
XML_FILE = File.expand_path(File.dirname(__FILE__) + "/vm.xml")
$VERBOSE = false

RSpec::Runner.configure do |config|
  config.before :each do
    [RRD_FILE, IMG_FILE].each{|file| `rm #{file} 2>&1`}
  end
  
end