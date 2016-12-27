require 'knn'

class CoffeeState
  include Singleton

  def self.state
    knn = Knn.new
    image = Magick::Image.read("http://gurula.wtf/kahvi/kahvi.jpg").first.minify
    return knn.classify(image)
  end

end
