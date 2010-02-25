module RRD
  class Graph
    GRAPH_OPTIONS = [:color, :label]
    DEF_OPTIONS= [:from]
    
    attr_accessor :output, :parameters, :definitions, :printables
    
    def initialize(output, parameters = {})
      @output = output
      @parameters = parameters
      @definitions = []
      @printables = []
    end
    
    def for_rrd_data(data_name, options)
      dataset = options.reject {|name, value| DEF_OPTIONS.include?(name.to_sym)}
      definition = "DEF:#{data_name}=#{options[:from]}:#{dataset.keys.first}:#{dataset.values.first.to_s.upcase}"
      definitions << definition
      definition
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
      definition = "DEF:#{name}=#{rrd_file}:#{dataset.keys.first}:#{dataset.values.first.to_s.upcase}"
      definitions << definition
      printable = "LINE1:#{name}#{options[:color]}:#{options[:label]}"
      printables << printable
      [definition, printable]
    end
    
    def area(rrd_file, options)
      dataset = options.reject {|name, value| GRAPH_OPTIONS.include?(name.to_sym)}
      name = "#{dataset.keys.first}_#{dataset.values.first.to_s}"
      definition = "DEF:#{name}=#{rrd_file}:#{dataset.keys.first}:#{dataset.values.first.to_s.upcase}"
      definitions << definition
      printable = "AREA:#{name}#{options[:color]}:#{options[:label]}"
      printables << printable
      [definition, printable]
    end
    
    def save
      args = [output]
      args += ["--title", parameters[:title]] if parameters[:title]
      args += definitions
      args += printables
      
      Wrapper.graph(*args)
    end
    
    private
    def draw(type, options)
      printable = "#{type}:#{options[:data]}#{options[:color]}:#{options[:label]}"
      printables << printable
      printable
    end
  end
end