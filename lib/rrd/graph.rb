module RRD
  class Graph
    GRAPH_OPTIONS = [:color, :label]
    GRAPH_TYPE = {:line => "LINE1", :area => "AREA"}
    
    attr_accessor :params, :output, :options
    
    def initialize(output, options = {})
      @output = output
      @options = options
      @params = []
    end
    
    def line(rrd_file, options = {})
      params << [:line, rrd_file, options]
    end
    
    def area(rrd_file, options = {})
      params << [:area, rrd_file, options]
    end
    
    def save
      args = [output]
      args += ["--title", options[:title]] if options[:title]
      
      params.each_with_index do |(type, file, opts), i|
        dataset = opts.reject {|name, value| GRAPH_OPTIONS.include?(name.to_sym)}
        args << "DEF:d#{i}=#{file}:#{dataset.keys.first}:#{dataset.values.first.to_s.upcase}"
        args << "#{GRAPH_TYPE[type.to_sym]}:d#{i}#{opts[:color]}:#{opts[:label]}"
      end
      
      Wrapper.graph(*args)
    end
  end
end