require 'nbayes'

class Lights

  include Singleton

  def initialize
    train *DataSource.instance.all_training_data(:dark, false)
  end

  def train(data, labels)
    @bayes = NBayes::Base.new
    labels = labels.map{|label| label == -100 ? "DARK" : "LIGHT"}

    data.zip(labels).each do |sample, label|
      @bayes.train sample, label
    end
  end

  def classify image_path
    obs = MiniMagick::Image.open(image_path).get_dark_pixels
    classified = @bayes.classify(obs)
    return "DARK" if classified["DARK"] and classified["DARK"] > 0.53
    "LIGHT"
  end
end
