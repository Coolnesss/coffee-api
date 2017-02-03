require 'coffee_state'
class CoffeeController < ApplicationController

  # Returns the state of coffee currently, one of:
  # EMPTY, BREWING, LOW, HALF, FULL
  def state
    render json: {
      state: CoffeeState.state
    }, status: 200
  end

  def sample
    sample_params = params.require(:sample).permit(:label)
    sample = Sample.new(sample_params)
    sample.image_from_gurula
    if sample.save
      LinearModel.instance.update_coefs sample.image.path, sample.label # TODO don't block on S3 retrieval
      render json: {
        label: sample_params[:label]
      }, status: 200
    else
      render json: {
      }, status: 400
    end
  end
end
