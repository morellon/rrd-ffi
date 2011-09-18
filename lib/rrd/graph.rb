# -*- coding: UTF-8 -*-
module RRD
  class Graph
    GRAPH_OPTIONS = [:color, :label]
    DEF_OPTIONS= [:from]
    GRAPH_FLAGS = [:only_graph, :full_size_mode, :rigid, :alt_autoscale, :no_gridfit,
             :alt_y_grid, :logarithmic, :no_legend, :force_rules_legend, :lazy,
             :pango_markup, :slope_mode, :interlaced] 
    
    attr_accessor :output, :parameters, :definitions, :printables
    
    def initialize(output, parameters = {})
      @output = output
      
      @parameters = {:start => Time.now - 1.day, :end => Time.now, :title => ""}.merge parameters
      @parameters[:start] = @parameters[:start].to_i
      @parameters[:end] = @parameters[:end].to_i
      
      @definitions = []
      @printables = []
    end
    
    def for_rrd_data(data_name, options)
      dataset = options.reject {|name, value| DEF_OPTIONS.include?(name.to_sym)}
      start_at = dataset[:start] && dataset.delete(:start)
      end_at   = dataset[:end] && dataset.delete(:end)
      step     = dataset[:step] && dataset.delete(:step)

      definition = "DEF:#{data_name}=#{options[:from]}:#{dataset.keys.first}:#{dataset.values.first.to_s.upcase}"
      definition += ":step=#{step.to_i}" unless step.nil?
      definition += ":start=#{start_at.to_i}" unless start_at.nil?
      definition += ":end=#{end_at.to_i}" unless end_at.nil?

      definitions << definition
      definition
    end
    
    def using_calculated_data(data_name, options)
      definition = "CDEF:#{data_name}=#{options[:calc]}"
      definitions << definition
      definition
    end
    
    def using_value(value_name, options)
      definition = "VDEF:#{value_name}=#{options[:calc]}"
      definitions << definition
      definition
    end
    
    def print_comment(comment)
      printable = "COMMENT:#{comment}"
      printables << printable
      printable
    end
    
    def shift(options)
      definition = "SHIFT:#{options.keys.first}:#{options.values.first}"
      definitions << definition
      definition
    end

    def print_value(value_name, options)
      printable = "GPRINT:#{value_name}:#{options[:format]}"
      printables << printable
      printable
    end

    def draw_line(options)
      options = {:width => 1}.merge options
      type = "LINE#{options[:width]}"
      draw(type, options)
    end
    
    def draw_area(options)
      draw("AREA", options)
    end

    def line(rrd_file, options)
      dataset = options.reject {|name, value| GRAPH_OPTIONS.include?(name.to_sym)}
      name = "#{dataset.keys.first}_#{dataset.values.first.to_s}"
      options = {:data => name}.merge(options)
      
      definition = for_rrd_data name, {:from => rrd_file}.merge(dataset)
      printable = draw_line options
      [definition, printable]
    end
    
    def area(rrd_file, options)
      dataset = options.reject {|name, value| GRAPH_OPTIONS.include?(name.to_sym)}
      name = "#{dataset.keys.first}_#{dataset.values.first.to_s}"
      options = {:data => name}.merge(options)
      
      definition = for_rrd_data name, {:from => rrd_file}.merge(dataset)
      printable = draw_area options
      [definition, printable]
    end

    def save    
      Wrapper.graph(*generate_args)
    end
    
    private
    def generate_args
      args = [output]
      args += RRD.to_line_parameters(parameters, GRAPH_FLAGS)
      args += definitions
      args += printables
    end
    
    def draw(type, options)
      printable = "#{type}:#{options[:data]}#{options[:color]}"

      if options[:label]
        options[:label] = options[:label].gsub(/^:/, "\\:").gsub(/([^\\]):/, "\\1\\:") # Escape all non-escaped ':'
        printable += ":#{options[:label]}"
      end

      if options[:extra]
        printable += ":#{options[:extra]}"
      end

      printables << printable
      printable
    end
  end
end