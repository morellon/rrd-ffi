module RRD
  class Base
    extend FFI::Library
  
    attr_accessor :rrd_file
  
    ffi_lib "/opt/local/lib/librrd.dylib"
    attach_function :rrd_restore, [:int, :pointer], :int
    attach_function :rrd_get_error, [], :string
    
    def initialize(rrd_file)
      @rrd_file = rrd_file
    end
  
    def create(*args)
    end
  
    def update(data)
    end
  
    def fetch(*args)
    end
  
    def info
    end
  
    def starts_at
    end
    alias :first :starts_at
  
    def ends_at
    end
    alias :last :ends_at
  
    def restore(xml_file)
      argv = RRD.to_pointer(["restore", xml_file, rrd_file])
      raise rrd_get_error unless rrd_restore(3, argv) == 0
      true
    end
  end
end