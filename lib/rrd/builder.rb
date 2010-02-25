module RRD
  class Builder
    attr_accessor :step, :datasources, :archives
    
    DATASOURCE_TYPES = [:gauge, :counter, :derive, :absolute]
    ARCHIVE_TYPES = [:average, :min, :max, :last]
        
    def initialize(rrd_file, options = {})
      options = {:step => 5.minutes}.merge options
      @step = options[:step]
      @datasources = []
      @archives = []
    end
    
    def datasource(name, options = {})
      options = {:type => :gauge, :heartbeat => 10.minutes, :min => 0, :max => :unlimited}.merge options
      options[:max] = "U" if options[:max] == :unlimited
      datasource = "DS:#{name}:#{options[:type].to_s.upcase}:#{options[:heartbeat]}:#{options[:min]}:#{options[:max]}"
      datasources << datasource
      datasource
    end
    
    def archive(consolidation_function, options = {})
      options = {:every => 5.minutes, :during => 1.day}.merge options
      archive_steps = options[:every]/step
      archive_rows = options[:during]/options[:every]
      archive = "RRA:#{consolidation_function.to_s.upcase}:0.5:#{archive_steps}:#{archive_rows}"
      archives << archive
      archive
    end
  end
end