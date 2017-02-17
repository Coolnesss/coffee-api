class SamplesController < ApplicationController

  def not_verified
     @samples = Sample.where(verified: false)
  end

  def create
    sample_params = params.require(:sample).permit(:label)
    sample = Sample.new(sample_params)
    sample.image_from_gurula
    if sample.save
      render json: {
        label: sample_params[:label]
      }, status: 200
    else
      render json: {
      }, status: 400
    end
  end

  def verify
    sample_params = params.require(:sample).permit(:verified)
    if params["token"] == ENV["COFFEE_TOKEN"]
      sample = Sample.find(params["id"])
      sample.update_attribute(:verified, sample_params[:verified])
      render json:{
      }, status: 200
    else
      render json:{
      }, status: 401
    end
  end

  def destroy
    sample = Sample.find(params["id"])
    if params["token"] == ENV["COFFEE_TOKEN"] and not sample.verified
      sample.destroy
      render json:{
      }, status: 200
    else
      render json:{
      }, status: 401
    end
  end
end
