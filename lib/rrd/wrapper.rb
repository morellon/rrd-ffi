module RRD
  # Raw RRD Tool wrapper.
  #
  # See http://oss.oetiker.ch/rrdtool/doc/rrdtool.en.html for details on the parameters
  class Wrapper
    
    INFO_TYPE = { 0 => :u_val, 1 => :u_cnt, 2 => :u_str, 3 => :u_int, 4 => :u_blob}
    BANG_METHODS = [:create!, :dump!, :fetch!, :first!, :graph!, :info!, :last!, :last_update!, :resize!, :restore!, :tune!, :update!]
    
    def self.detect_rrd_lib
      if defined?(RRD_LIB)
        RRD_LIB
      elsif ENV["RRD_LIB"]
        ENV["RRD_LIB"] 
      else
        "rrd"
      end
    end
    
    class RRDBlob < FFI::Struct
      layout :size,  :ulong,
             :ptr, :pointer
    end
    
    class RRDInfoVal < FFI::Union
      layout :u_cnt,  :ulong,
             :u_val, :double,
             :u_str, :string,
             :u_int,  :int,
             :u_blob, RRDBlob
    end
    
    class RRDInfo < FFI::Struct
      layout :key,  :string,
             :type, :uint,
             :value, RRDInfoVal,
             :next,  :pointer
    end
    
    class << self
      extend FFI::Library

      ffi_lib RRD::Wrapper.detect_rrd_lib
      attach_function :rrd_create, [:int, :pointer], :int
      attach_function :rrd_dump, [:int, :pointer], :int
      attach_function :rrd_fetch, [:int, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :int
      attach_function :rrd_first, [:int, :pointer], :time_t
      attach_function :rrd_graph, [:int, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :int
      attach_function :rrd_info, [:int, :pointer], :pointer
      attach_function :rrd_last, [:int, :pointer], :time_t
      attach_function :rrd_lastupdate_r, [:string, :pointer, :pointer, :pointer, :pointer], :int
      attach_function :rrd_resize, [:int, :pointer], :int
      attach_function :rrd_restore, [:int, :pointer], :int
      attach_function :rrd_tune, [:int, :pointer], :int
      attach_function :rrd_update, [:int, :pointer], :int
            
      attach_function :rrd_get_error, [], :string
      attach_function :rrd_clear_error, [], :void
      
      # Set up a new Round Robin Database (RRD).
      def create(*args)
        argv = to_pointer(["create"] + args)
        rrd_create(args.size+1, argv) == 0
        true
      end
      
      # Dump a binary RRD to an RRD in XML format.
      def dump(*args)
        argv = to_pointer(["dump"] + args)
        rrd_dump(args.size+1, argv) == 0
      end
      
      # Get data for a certain time period from a RRD.
      # 
      # Returns an array of arrays (which contains the date and values for all datasources):
      #
      #   [["time"    , "cpu", "memory"],
      #    [1266933600, "0.5", "511"   ],
      #    [1266933900, "0.9", "253"   ]]
      #
      def fetch(*args)
        #FIXME: Refactor this
        start_time_ptr = empty_pointer
        end_time_ptr = empty_pointer
        step_ptr = empty_pointer
        ds_count_ptr = empty_pointer
        ds_names_ptr = empty_pointer
        
        values_ptr = FFI::MemoryPointer.new(:pointer)
        argv = to_pointer(["fetch"] + args)
        return false unless rrd_fetch(args.size+1, argv, start_time_ptr, end_time_ptr, step_ptr, ds_count_ptr, ds_names_ptr, values_ptr) == 0
        
        ds_count = ds_count_ptr.get_int(0)
        start_time = start_time_ptr.get_int(0)
        end_time = end_time_ptr.get_int(0)
        step = step_ptr.get_int(0)
        
        result_lines = (end_time-start_time)/step
        
        ds_names = ds_names_ptr.get_pointer(0).get_array_of_string(0, ds_count)
        values = values_ptr.get_pointer(0).get_array_of_double(0, result_lines * ds_count)
        
        result = [["time"] + ds_names]
        (0..result_lines-1).each do |line|
          date = start_time + line*step
          first = ds_count*line
          last = ds_count*line + ds_count - 1
          result << [date] + values[first..last]
        end
        
        result
      end
      
      # Find the first update time of an RRD.
      #  
      # Returns an integer unix time
      def first(*args)
        argv = to_pointer(["first"] + args)
        date = rrd_first(args.size+1, argv)
        return false if date == -1
        date
      end
      
      # Create a graph from data stored in one or several RRDs.
      def graph(*args)
        argv = to_pointer(["graph"] + args)
        xsize_ptr = empty_pointer
        ysize_ptr = empty_pointer
        ymin_ptr = empty_pointer
        ymax_ptr = empty_pointer
        rrd_graph(args.size+1, argv, empty_pointer, xsize_ptr, ysize_ptr, empty_pointer, ymin_ptr, ymax_ptr) == 0
      end
      
      # Get information about an RRD.
      # 
      # Returns a hash with the information
      def info(*args)
        argv = to_pointer(["info"] + args)
        result = rrd_info(args.size+1, argv)
    
        info = {}
        while result.address != 0
          item = RRD::Wrapper::RRDInfo.new result
          info[item[:key]] = item[:value][INFO_TYPE[item[:type]].to_sym]
          result = item[:next]
        end
        
        return false if info.empty?
        info
      end
      
      # Find the last update time of an RRD.
      #
      # Returns an integer unix time
      def last(*args)
        argv = to_pointer(["last"] + args)
        date = rrd_last(args.size+1, argv)
        return false if date == -1
        date
      end
      
      # Get the last entered data.
      # 
      # Returns an array of 2 arrays (one with datasource names and other with the values):
      #
      #   [["time"    , "cpu", "memory"],
      #    [1266933900, "0.9", "253"   ]]
      # 
      def last_update(file)
        update_time_ptr = empty_pointer
        ds_count_ptr = empty_pointer
        ds_names_ptr = empty_pointer
        values_ptr = FFI::MemoryPointer.new(:pointer)
        
        return false if rrd_lastupdate_r(file, update_time_ptr, ds_count_ptr, ds_names_ptr, values_ptr) == -1
        update_time = update_time_ptr.get_ulong(0)
        ds_count = ds_count_ptr.get_ulong(0)
        ds_names = ds_names_ptr.get_pointer(0).get_array_of_string(0, ds_count)
        values = values_ptr.get_pointer(0).get_array_of_string(0, ds_count)
        values = values.map {|item| item.include?(".")? item.to_f : item.to_i} # Converting string to numeric

        [["time"] + ds_names, [update_time]+values]
      end
      
      # Used to modify the number of rows in an RRA
      def resize(*args)
        argv = to_pointer(["resize"] + args)
        rrd_resize(args.size+1, argv) == 0
      end

      # Restore an RRD in XML format to a binary RRD.
      def restore(*args)
        argv = to_pointer(["restore"] + args)
        rrd_restore(args.size+1, argv) == 0
      end
      
      # Allows you to alter some of the basic configuration values
      # stored in the header area of a Round Robin Database.
      def tune(*args)
        argv = to_pointer(["tune"] + args)
        rrd_tune(args.size+1, argv) == 0
      end
      
      # Store new data values into an RRD.
      def update(*args)
        argv = to_pointer(["update"] + args)
        rrd_update(args.size+1, argv) == 0
      end
      
      # Returns the error happened.
      def error
        rrd_get_error
      end
      
      # Clear the error message.
      def clear_error
        rrd_clear_error
      end
      
      def methods
        super + BANG_METHODS
      end

      def bang(method, *args, &block)
        result = send(method, *args, &block)
        raise error unless result
        result
      end

      # Defining all bang methods
      BANG_METHODS.each do |bang_method|
        define_method(bang_method) do |*args, &block|
          method = bang_method.to_s.match(/^(.+)!$/)[1]
          bang(method, *args, &block)
        end
      end
   
      private
      def empty_pointer
        FFI::MemoryPointer.new(:pointer)
      end

      # FIXME: remove clear_error from here
      def to_pointer(array_of_strings)
        clear_error
        strptrs = []
        array_of_strings.each {|item| strptrs << FFI::MemoryPointer.from_string(item)}

        argv = FFI::MemoryPointer.new(:pointer, strptrs.length)
        strptrs.each_with_index do |p, i|
          argv[i].put_pointer(0,  p)
        end

        argv
      end
    end
  end
end