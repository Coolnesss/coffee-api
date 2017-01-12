require 'nmatrix'

class LinearModel

  include Singleton

  attr_reader :coefs, :data

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/regression_labels.json'
  LABELS = JSON.parse(IO.read(LABEL_PATH))

  def initialize
    train
  end

  def train(train_image_names = all_training_names)
    @data = train_image_names.map{|image_name| MiniMagick::Image.new(image_name).get_good_pixels}.map{|x| x.prepend(1)}
    labels = train_image_names.map{|x| LABELS[x.split("/").last]}
    labels = NMatrix.new [train_image_names.size,1], labels, dtype: :float64

    m = NMatrix.new [@data.size, @data.first.size], @data.flatten, dtype: :int32
    @coefs = apply_formula(m, labels)
  end

  def apply_formula(matrix, labels)
    (matrix.transpose.dot(matrix)).inverse.dot(matrix.transpose).dot(labels)
  end

  def predict(image_path)
    obs = MiniMagick::Image.open(image_path).get_good_pixels
    result = @coefs[0] + (@coefs.drop(1).zip(obs).inject(0){|sum,(x,y)| sum + (x*y)})
    return 0 if result < 0
    result.round05
  end

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x.include? 'json' or x.include? "dark"
    }.map{|x| (DATA_PATH + x)}
  end

end
