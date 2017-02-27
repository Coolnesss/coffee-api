class HybridClassifier
  include Singleton

  def initialize
    train *DataSource.instance.all_training_data
  end

  def train(data, labels)
    LinearModel.instance
    Lights.instance
  end

  def classify(image_path)

  end

end
