require 'linear_model'
require 'lights'

class HybridClassifier
  include Singleton

  def classify(image_path)
    return "NO POT" if Lights.instance.classify(image_path) == "DARK"
    LinearModel.instance.predict image_path
  end

end
