require "ffi"
require "rrd/wrapper"
require "rrd/base"
require "rrd/graph"

module RRD
  extend self
  
  def graph(image_file, options, &block)
    graph = Graph.new(image_file, options)
    graph.instance_eval(&block)
    graph.save
  end
end

