module RRD
  class Base
    attr_accessor :rrd_file
    
    def initialize(rrd_file)
      @rrd_file = rrd_file
    end
  
    def starts_at
      Time.at Wrapper.first(rrd_file)
    end
    alias :first :starts_at
  
    def ends_at
      Time.at Wrapper.last(rrd_file)
    end
    alias :last :ends_at
  
    def restore(xml_file)
      Wrapper.restore(xml_file, rrd_file)
    end
  end
end