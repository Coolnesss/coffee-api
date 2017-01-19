require 'nmatrix'

class LinearModel
  include Singleton
  attr_reader :coefs, :data

  def initialize
    train *DataSource.instance.all_training_data
  end

  def train(data, labels)
    @data = data.map{|x| [1.0] + x}
    labels = NMatrix.new [labels.size, 1], labels, dtype: :float64
    m = NMatrix.new [@data.size, @data.first.size], @data.flatten, dtype: :int32
    @coefs = apply_formula(m, labels)
  end

  def predict(image_path)
    obs = MiniMagick::Image.open(image_path).get_good_pixels
    result = @coefs[0] + (@coefs.drop(1).zip(obs).inject(0){|sum,(x,y)| sum + (x*y)})
    return 0 if result < 0
    result.round05
  end

  private

  def apply_formula(matrix, labels)
    (matrix.transpose.dot(matrix)).inverse.dot(matrix.transpose).dot(labels)
  end

end
