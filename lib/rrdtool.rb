require "ffi"

class RRD
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
    argv = to_pointer(["restore", xml_file, rrd_file])
    raise rrd_get_error unless rrd_restore(3, argv) == 0
    true
  end
  
  def graph(image_file, *args)
    
  end
  
  private
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