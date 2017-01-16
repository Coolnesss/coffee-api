class Naive

    DATA_PATH = 'lib/training_data/'
    LABEL_PATH = 'lib/training_data/labels.json'

    def all_training_names
      image_names = Dir.entries(DATA_PATH).reject{ |x|
        x == '.' or x == '..' or x == 'labels.json'
      }.map{|x| (DATA_PATH + x)}
    end

  def classify(image_path, train_image_names = all_training_names)
    coffee_brown = [39, 35, 24]
    #image = "lib/training_data/kahvi.jpg"
    images = train_image_names.map{|x| MiniMagick::Image.new(x)}
    labels = JSON.parse IO.read(LABEL_PATH)
    image_pixels = images.map(&:get_pixels)

    distances = image_pixels.map{|image| image.inject(0){|sum, x| dist(x, coffee_brown)}}
    sorted = distances.sort
  end

  # [1,2,3] vs [1,2,3]
  def dist(x,y)
    x.zip(y).inject(0){|sum, (x ,y)| sum + (x - y).abs}
  end

end
