module RRD
  class Graph
    extend FFI::Library
    
    ffi_lib "/opt/local/lib/librrd.dylib"
    attach_function :rrd_graph, [:int, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :int
    attach_function :rrd_get_error, [], :string
    
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
      args = ["graph", output]
      args += ["--title", options[:title]] if options[:title]
      
      params.each_with_index do |(type, file, opts), i|
        dataset = opts.reject {|name, value| GRAPH_OPTIONS.include?(name.to_sym)}
        args << "DEF:d#{i}=#{file}:#{dataset.keys.first}:#{dataset.values.first.to_s.upcase}"
        args << "#{GRAPH_TYPE[type.to_sym]}:d#{i}#{opts[:color]}:#{opts[:label]}"
      end
      
      Graph.raw(*args)
    end
    
    def self.raw(*args)
      argv = RRD.to_pointer(args)
      raise rrd_get_error unless rrd_graph(args.size, argv, *Array.new(6, RRD.empty_pointer)) == 0
      true
    end
  end
end