require 'coffee_state'
class CoffeeController < ApplicationController

  # Returns the state of coffee currently, one of:
  # EMPTY, BREWING, LOW, HALF, FULL
  def state
    render json: {
      state: CoffeeState.state
    }, status: 200
  end

end
