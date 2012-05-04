# -*- coding: UTF-8 -*-
require "ffi"
require "rrd/version"
require "rrd/wrapper"
require "rrd/base"
require "rrd/graph"
require "rrd/xport"
require "rrd/builder"
require "rrd/time_extension"

module RRD
  extend self

  BANG_METHODS = [:graph!, :xport!]

  def graph(image_file, options = {}, &block)
    graph = Graph.new(image_file, options)
    graph.instance_eval(&block)
    graph.save
  end

  def xport(options = {}, &block)
    xport = Xport.new(options)
    xport.instance_eval(&block)
    xport.save
  end

  def error
    Wrapper.error
  end

  def to_line_parameters(hash, known_flags = [])
    used_flags = []
    known_flags.each do |flag|
      used_flags << "--#{flag}".gsub(/_/, "-") if hash.delete(flag)
    end

    line_params = []

    hash.each_pair do |key,value|
      if value.kind_of? Array
        value.each {|v| line_params += ["--#{key}".gsub(/_/, "-"), v.to_s]}
      else
        line_params += ["--#{key}".gsub(/_/, "-"), value.to_s]
      end
    end

    used_flags + line_params
  end

  def methods
    super + BANG_METHODS
  end

  def bang(method, *args, &block)
    result = send(method, *args, &block)
    raise error unless result
    result
  end

  # Defining all bang methods
  BANG_METHODS.each do |bang_method|
    class_eval "
      def #{bang_method}(*args, &block)
        method = \"#{bang_method}\".match(/^(.+)!$/)[1]
        bang(method, *args, &block)
      end
    "
  end
end

