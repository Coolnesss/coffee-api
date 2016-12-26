class CoffeeController < ApplicationController

  # Returns the state of coffee currently, one of:
  # NONE, BREWING, LOW, HALF, FULL
  def state
    render json: {
      state: "BREWING"
    }, status: 200
  end
end
