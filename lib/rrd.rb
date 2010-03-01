require "ffi"
require "rrd/version"
require "rrd/wrapper"
require "rrd/base"
require "rrd/graph"
require "rrd/builder"
require "rrd/ext/fixnum"

module RRD
  extend self
  
  def graph(image_file, options = {}, &block)
    graph = Graph.new(image_file, options)
    graph.instance_eval(&block)
    graph.save
  end
  
  def to_line_parameters(hash, known_flags = [])
    used_flags = []
    known_flags.each do |flag|
      used_flags << "--#{flag}".gsub(/_/, "-") if hash.delete(flag)
    end
    
    line_params = Hash[*hash.reduce([]) { |result, (key,value)| result += ["--#{key}".gsub(/_/, "-"), value.to_s] }]
    params = line_params.keys.sort.reduce([]) { |result, key| result += [key, line_params[key]] }
    used_flags + params
  end
end

