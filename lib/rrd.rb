require "ffi"
require "rrd/base"
require "rrd/graph"

module RRD
  extend self
  
  def graph(image_file, options, &block)
    graph = Graph.new(image_file, options)
    graph.instance_eval(&block)
    graph.save
  end
  
  def empty_pointer
    FFI::MemoryPointer.new(:pointer, 0)
  end
  
  def to_pointer(array_of_strings)
    strptrs = []
    array_of_strings.each {|item| strptrs << FFI::MemoryPointer.from_string(item)}

    argv = FFI::MemoryPointer.new(:pointer, strptrs.length)
    strptrs.each_with_index do |p, i|
      argv[i].put_pointer(0,  p)
    end
  
    argv
  end
end

