class HybridClassifier
  include Singleton

  def initialize
    LinearModel.instance
    Lights.instance
  end


end
