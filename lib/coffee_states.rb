module CoffeeStates
  EMPTY=0
  LOW=0.5
  HALF=1
  FULL=2
  DARK=10
  NOT_SURE=3

  def self.get_value(constant)
    self.const_get(constant)
  end

  def self.get_constant(value)
    self.constants.find{|x| CoffeeStates.get_value(x) == value}
  end

  def self.encode(labels)
    labels.map{|x| CoffeeStates.get_value(x)}
  end

  def self.decode(indices)
    indices.map{|x| CoffeeStates.get_constant(x)}
  end

end
