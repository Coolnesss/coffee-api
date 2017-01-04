require 'knn'

class CoffeeState
  include Singleton

  @previous_value = nil
  @previous_time = 1.minute.ago

  def self.state
    if (Time.now - @previous_time) > 30.seconds
      @previous_value = fetch_state
      @previous_time = Time.now
    end
    @previous_value
  end

  def self.fetch_state
    return Knn.new.classify "http://gurula.wtf/kahvi/kahvi.jpg"
  end

end
