require 'nmatrix'
require 'data_source'

class LinearModel
  include Singleton
  attr_reader :coefs, :data

  def initialize
    train *DataSource.instance.all_training_data
  end

  def train(data, labels)
    data = data.map{|x| [1.0] + x}
    labels = NMatrix.new [labels.size, 1], labels, dtype: :float64
    m = NMatrix.new [data.size, data.first.size], data.flatten, dtype: :int32
    @coefs = apply_formula(m, labels)
  end

  def predict(image_path)
    obs = MiniMagick::Image.open(image_path).get_good_pixels
    result = predict_formula obs
    return 0 if result < 0
    binding.pry
    result.round05
  end

  # Stochastic gradient descent for online updating for the coefs
  def update_coefs(sample_path, label)
    sample = [1] + MiniMagick::Image.open(sample_path).get_good_pixels if Rails.env.development?
    sample = [1] + MiniMagick::Image.open(sample_path).get_good_pixels if Rails.env.production?
    step_size = 0.001
    output = predict_formula sample
    @coefs = @coefs.map.with_index do |coef, index|
      coef + step_size * (label - output) * sample[index]
    end
  end

  private

  def predict_formula(sample)
    @coefs[0] + (@coefs.drop(1).zip(sample).inject(0){|sum,(x,y)| sum + (x*y)})
  end

  def apply_formula(matrix, labels)
    (matrix.transpose.dot(matrix)).inverse.dot(matrix.transpose).dot(labels)
  end

end
