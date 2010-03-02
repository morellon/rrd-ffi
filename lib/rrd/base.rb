module RRD
  # TODO: add bang methods
  class Base
    attr_accessor :rrd_file
    
    BANG_METHODS = [:create!, :dump!, :ends_at!, :fetch!, :first!, :info!, :last!, :last_update!, :restore!, :starts_at!, :update!]
    
    RESTORE_FLAGS = [:force_overwrite, :range_check]
    DUMP_FLAGS = [:no_header]

    def initialize(rrd_file)
      @rrd_file = rrd_file
    end
    
    def error
      Wrapper.error
    end
    
    def create(options = {}, &block)
      builder = RRD::Builder.new(rrd_file, options)
      builder.instance_eval(&block)
      builder.save
    end
    
    def dump(xml_file, options = {})
      options = options.clone
      line_params = RRD.to_line_parameters(options, DUMP_FLAGS)
      Wrapper.dump(rrd_file, xml_file, *line_params)
    end
    
    # Returns a time object with the last entered value date
    def ends_at
      Time.at Wrapper.last(rrd_file)
    end
    alias :last :ends_at
    
    # Basic usage: rrd.fetch :average 
    #
    def fetch(consolidation_function, options = {})
      options = {:start => Time.now - 1.day, :end => Time.now}.merge options
      
      options[:start] = options[:start].to_i
      options[:end] = options[:end].to_i
      line_params = RRD.to_line_parameters(options)
      
      Wrapper.fetch(rrd_file, consolidation_function.to_s.upcase, *line_params)
    end
    
    # See RRD::Wrapper.info
    def info
      Wrapper.info(rrd_file)
    end
    
    # See RRD::Wrapper.last_update
    def last_update
      Wrapper.last_update(rrd_file)
    end
    
    # See RRD::Wrapper.restore
    def restore(xml_file, options = {})
      options = options.clone
      line_params = RRD.to_line_parameters(options, RESTORE_FLAGS)
      Wrapper.restore(xml_file, rrd_file, *line_params)
    end
    
    # Returns a time object with the first entered value date
    def starts_at
      Time.at Wrapper.first(rrd_file)
    end
    alias :first :starts_at
    
    # Basic usage: rrd.update Time.now, 20.0, 20, nil, 2
    #
    # Note: All datasources must receive a value, based on datasources order in rrd file
    def update(time, *data)
      new_data = data.map {|item| item.nil? ? "U" : item}
      new_data = [time.to_i] + new_data
      
      Wrapper.update(rrd_file, new_data.join(":"))
    end
    
    
    def methods
      super + BANG_METHODS
    end
    
    def bang(method, *args)
      result = send(method, *args)
      raise error unless result
      result
    end
 
    # Defining all bang methods
    BANG_METHODS.each do |bang_method|
      define_method(bang_method) do |*args|
        method = bang_method.to_s.match(/^(.+)!$/)[1]
        bang(method, *args)
      end
    end
    
  end
end