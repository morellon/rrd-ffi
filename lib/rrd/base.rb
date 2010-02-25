module RRD
  class Base
    attr_accessor :rrd_file
      
    def initialize(rrd_file)
      @rrd_file = rrd_file
    end
    
    # Basic usage: rrd.update Time.now, 20.0, 20, nil, 2
    #
    # Note: All datasources must receive a value, based on datasources order in rrd file
    def update(time, *data)
      new_data = data.map {|item| item.nil? ? "U" : item}
      new_data = [time.to_i] + new_data
      Wrapper.update(rrd_file, new_data.join(":"))
    end
    
    # Basic usage: rrd.fetch :average 
    #
    def fetch(consolidation_function, options = {:start => Time.now - 87840, :end => Time.now})
      options[:start] = options[:start].to_i
      options[:end] = options[:end].to_i
      line_params = options.reduce([]){|result, (key, value)| result += ["--#{key}", value.to_s]}
      
      Wrapper.fetch(rrd_file, consolidation_function.to_s.upcase, *line_params)
    end
    
    # See RRD::Wrapper.info
    def info
      Wrapper.info(rrd_file)
    end
    
    # Returns a time object with the first entered value date
    def starts_at
      Time.at Wrapper.first(rrd_file)
    end
    alias :first :starts_at
  
    # Returns a time object with the last entered value date
    def ends_at
      Time.at Wrapper.last(rrd_file)
    end
    alias :last :ends_at
  
    # See RRD::Wrapper.restore
    def restore(xml_file)
      Wrapper.restore(xml_file, rrd_file)
    end
  end
end