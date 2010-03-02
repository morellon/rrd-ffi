require "rubygems"
require "spec"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require "rrd"

$VERBOSE = nil
RRD_FILE = File.expand_path(File.dirname(__FILE__) + "/vm.rrd")
IMG_FILE = File.expand_path(File.dirname(__FILE__) + "/vm.png")
XML_FILE = File.expand_path(File.dirname(__FILE__) + "/vm.xml")
$VERBOSE = false

Spec::Runner.configure do |config|
  config.append_before :each do
    [RRD_FILE, IMG_FILE].each{|file| FileUtils.rm file rescue nil}
  end
  
end