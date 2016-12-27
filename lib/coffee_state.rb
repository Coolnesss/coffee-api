class CoffeeState
  include Singleton

  def self.state
    return "BREWING"
  end

end
