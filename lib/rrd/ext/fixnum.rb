#TODO: Change to ActiveSupport from Rails 3
class Fixnum
  def second
    self
  end
  alias :seconds :second
  
  def minute
    second * 60
  end
  alias :minutes :minute
  
  def hour
    minute * 60
  end
  alias :hours :hour
  
  def day
    hour * 24
  end
  alias :days :day
  
  def week
    day * 7
  end
  alias :weeks :week
  
  def month
    day * 30
  end
  alias :months :month
  
  def year
    day * 365
  end
  alias :years :year
end
  
  