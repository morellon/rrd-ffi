module RRD
  class Wrapper
    class << self
      extend FFI::Library

      ffi_lib "/opt/local/lib/librrd.dylib"
      attach_function :rrd_create, [:int, :pointer], :int
      attach_function :rrd_update, [:int, :pointer], :int
      attach_function :rrd_info, [:int, :pointer], :int
      attach_function :rrd_fetch, [:int, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :int
      attach_function :rrd_first, [:int, :pointer], :time_t
      attach_function :rrd_last, [:int, :pointer], :time_t
      attach_function :rrd_restore, [:int, :pointer], :int
      attach_function :rrd_graph, [:int, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :int
      attach_function :rrd_get_error, [], :string
      
      def create(*args)
        argv = to_pointer(["create"] + args)
        raise rrd_get_error unless rrd_create(args.size+1, argv) == 0
        true
      end

      def update(*args)
        argv = to_pointer(["update"] + args)
        raise rrd_get_error unless rrd_update(args.size+1, argv) == 0
        true
      end

      def fetch(*args)
        raise "not implemented"
        values = FFI::MemoryPointer.new(:pointer, 0)
        argv = to_pointer(["fetch"] + args)
        raise rrd_get_error unless rrd_fetch(args.size+1, argv, empty_pointer, empty_pointer, empty_pointer, empty_pointer, empty_pointer, values) == 0
        values
      end
      
      def info(*args)
        raise "not implemented"
        argv = to_pointer(["info"] + args)
        info = rrd_info(args.size+1, argv)
      end
      
      def first(*args)
        argv = to_pointer(["first"] + args)
        date = rrd_first(args.size+1, argv)
        raise rrd_get_error if date == -1
        date
      end
      
      def last(*args)
        argv = to_pointer(["last"] + args)
        date = rrd_last(args.size+1, argv)
        raise rrd_get_error if date == -1
        date
      end
      
      def restore(*args)
        argv = to_pointer(["restore"] + args)
        raise rrd_get_error unless rrd_restore(args.size+1, argv) == 0
        true
      end
      
      def graph(*args)
        argv = to_pointer(["graph"] + args)
        raise rrd_get_error unless rrd_graph(args.size+1, argv, *Array.new(6, empty_pointer)) == 0
        true
      end
      
      private
      def empty_pointer
        FFI::MemoryPointer.new(:pointer, 0)
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