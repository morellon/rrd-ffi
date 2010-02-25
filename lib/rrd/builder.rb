module RRD
  class Builder
    attr_accessor :output, :parameters, :datasources, :archives
    
    DATASOURCE_TYPES = [:gauge, :counter, :derive, :absolute]
    ARCHIVE_TYPES = [:average, :min, :max, :last]
        
    def initialize(output, parameters = {})
      @output = output
      
      @parameters = {:step => 5.minutes, :start => Time.now - 10.seconds }.merge parameters
      @parameters[:start] = @parameters[:start].to_i
      
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
      archive_steps = options[:every]/parameters[:step]
      archive_rows = options[:during]/options[:every]
      archive = "RRA:#{consolidation_function.to_s.upcase}:0.5:#{archive_steps}:#{archive_rows}"
      archives << archive
      archive
    end
    
    def save
      args = [output]
      line_parameters = RRD.to_line_parameters(parameters)
      args += line_parameters
      args += datasources
      args += archives
      
      Wrapper.create(*args)
    end
  end
end