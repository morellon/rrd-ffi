module RRD
  # Raw RRD Tool wrapper.
  #
  # See http://oss.oetiker.ch/rrdtool/doc/rrdtool.en.html for details on the parameters
  class Wrapper
    
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
      
      INFO_TYPE = { 0 => :u_val, 1 => :u_cnt, 2 => :u_str, 3 => :u_int, 4 => :u_blob}
      
      def self.rrd_lib
        if defined?(RRD_LIB)
          RRD_LIB
        elsif ENV["RRD_LIB"]
          ENV["RRD_LIB"] 
        else
          "rrd"
        end
      end

      ffi_lib rrd_lib
      attach_function :rrd_create, [:int, :pointer], :int
      attach_function :rrd_update, [:int, :pointer], :int
      attach_function :rrd_info, [:int, :pointer], :pointer
      attach_function :rrd_fetch, [:int, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :int
      attach_function :rrd_first, [:int, :pointer], :time_t
      attach_function :rrd_last, [:int, :pointer], :time_t
      attach_function :rrd_restore, [:int, :pointer], :int
      attach_function :rrd_graph, [:int, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :int
      attach_function :rrd_get_error, [], :string
      
      # Set up a new Round Robin Database (RRD).
      def create(*args)
        argv = to_pointer(["create"] + args)
        raise rrd_get_error unless rrd_create(args.size+1, argv) == 0
        true
      end

      # Store new data values into an RRD.
      def update(*args)
        argv = to_pointer(["update"] + args)
        raise rrd_get_error unless rrd_update(args.size+1, argv) == 0
        true
      end

      # Get data for a certain time period from a RRD.
      # 
      # Returns an array of arrays (which contains the date and values for all datasources)
      def fetch(*args)
        #FIXME: Refactor this
        start_time_ptr = empty_pointer
        end_time_ptr = empty_pointer
        step_ptr = empty_pointer
        ds_count_ptr = empty_pointer
        ds_names_ptr = empty_pointer
        
        values = FFI::MemoryPointer.new(:pointer)
        argv = to_pointer(["fetch"] + args)
        raise rrd_get_error unless rrd_fetch(args.size+1, argv, start_time_ptr, end_time_ptr, step_ptr, ds_count_ptr, ds_names_ptr, values) == 0
        
        ds_count = ds_count_ptr.get_int(0)
        start_time = start_time_ptr.get_int(0)
        end_time = end_time_ptr.get_int(0)
        step = step_ptr.get_int(0)
        
        result_lines = (end_time-start_time)/step
        result = []
        (0..result_lines-1).each do |i|
          data = []
          data << start_time + i*step
          (0..ds_count-1).each do |j|
            data << values.get_pointer(0)[8*(ds_count*i+j)].get_double(0)
          end
          result << data
        end
        
        result
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
        
        info
      end
      
      # Find the first update time of an RRD.
      #  
      # Returns an integer unix time
      def first(*args)
        argv = to_pointer(["first"] + args)
        date = rrd_first(args.size+1, argv)
        raise rrd_get_error if date == -1
        date
      end
      
      # Find the last update time of an RRD.
      #
      # Returns an integer unix time
      def last(*args)
        argv = to_pointer(["last"] + args)
        date = rrd_last(args.size+1, argv)
        raise rrd_get_error if date == -1
        date
      end
      
      # Restore an RRD in XML format to a binary RRD.
      def restore(*args)
        argv = to_pointer(["restore"] + args)
        raise rrd_get_error unless rrd_restore(args.size+1, argv) == 0
        true
      end
      
      # Create a graph from data stored in one or several RRDs.
      def graph(*args)
        argv = to_pointer(["graph"] + args)
        raise rrd_get_error unless rrd_graph(args.size+1, argv, *Array.new(6, empty_pointer)) == 0
        true
      end
      
      private
      def empty_pointer
        FFI::MemoryPointer.new(:pointer)
      end

      def to_pointer(array_of_strings)
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