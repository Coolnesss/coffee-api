require 'nbayes'

class Lights

  include Singleton

  def initialize
    @bayes = NBayes::Base.new
    data, labels = *DataSource.new(:get_dark_pixels).all_training_data
    labels = labels.map{|label| label == -100 ? "DARK" : "LIGHT"}
    data.zip(labels).each do |sample, label|
      @bayes.train sample, label
    end
  end

  def classify image_path
    obs = MiniMagick::Image.open(image_path).get_dark_pixels rescue binding.pry
    classified = @bayes.classify(obs)
    return "DARK" if classified["DARK"] > 0.53
    "LIGHT"
  end



end
