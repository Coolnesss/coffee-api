require 'nbayes'

class Lights

  include Singleton

  def initialize
    @bayes = NBayes::Base.new
    data, labels = *DataSource.instance.all_training_data
    data.zip(labels).each do |sample, label|
      @bayes.train sample, label
    end
  end

  def classify image_path
    obs = MiniMagick::Image.open(image_path).get_good_pixels
    @bayes.classify(obs)
  end



end
