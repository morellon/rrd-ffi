module RRD
  class Builder
    attr_accessor :step
    
    def initialize(step = 5.minutes)
      @step = step
    end
    
    def datasource(name, options = {:type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited})
    end
    
    def archive(consolidation_function, options = {:every => 5.minutes, :during => 1.day})
      
    end
  end
end