# -*- coding: UTF-8 -*-
require 'digest/md5'
module RRD
  class Xport
    attr_accessor :output, :parameters, :definitions, :printables

    DEF_OPTIONS= [:from]
    
    def initialize(parameters = {})      
      @parameters = {:start => Time.now - 1.day, :end => Time.now}.merge parameters
      @parameters[:start] = @parameters[:start].to_i
      @parameters[:end] = @parameters[:end].to_i
      
      @definitions = []
      @printables = []
    end
    
    def for_rrd_data(data_name, options)  
      dataset = options.reject {|name, value| DEF_OPTIONS.include?(name.to_sym)}
      definition = "DEF:#{data_name}=#{options[:from]}:#{dataset.keys.first}:#{dataset.values.first.to_s.upcase}"
      definitions << definition
      definition
    end
    
    def using_calculated_data(data_name, options)
      definition = "CDEF:#{data_name}=#{options[:calc]}"
      definitions << definition
      definition
    end
    
    def xport(data_name, options)            
      printable = "XPORT:#{data_name}:#{options[:label].gsub(/:/, '\\:')}"
      printables << printable
      [printable]
    end
    
    def save    
      Wrapper.xport(*generate_args)
    end
    
    private
    def generate_args
      args = []
      args += RRD.to_line_parameters(parameters)
      args += definitions
      args += printables
    end    
  end
end