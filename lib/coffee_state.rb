require 'linear_model'
require 'lights'
require 'hybrid_classifier'

class CoffeeState
  include Singleton

  IMAGE_URL = "http://gurula.wtf/kahvi/kahvi.jpg"

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
    HybridClassifier.instance.classify IMAGE_URL
  end
end
