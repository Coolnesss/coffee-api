class NaiveBayes

  include Singleton

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'

  def initialize
    @model={}
    train
  end

  def classify(image)

  end


  def train(train_image_names=all_training_names)
    matrix=[]
    images = train_image_names.map{|x| MiniMagick::Image.new(x)}
    labels = JSON.parse IO.read(LABEL_PATH)
    image_pixels = images.map(&:get_pixels)

    labels.values.uniq.each{|x| @model[x] = [{:MEAN => 0, :SD => 0}] * image_pixels.first.size }

    image_pixels.size.times do |i|
      image = images[i]
      pixels = image_pixels[i]
      label = labels[image.path.split("/").last]
      pixels.size.times do |j|
        binding.pry
        @model[label][j][:MEAN] += pixels[j]

      end
    end
    binding.pry


    #sd
    image_pixels.size.times do |i|
      image = images[i]
      pixels = image_pixels[i]

      pixel_array.size.times do |j|
        pixel = pixels[j]
        @model[labels[image.path.split("/").last]][j][0] += pixel
      end
    end

    labels.values.uniq.each do |label|
      label_image_names = {}
      labels.select{|k,v| v == label}.map{|k,v| label_image_names[DATA_PATH+k] = v}
      label_images = images.select{|i| label_image_names.keys.include? i.path }





      label_images.each do |pic|
        pixels = pic.get_pixels
        mean = pixels.sum / pixels.size
        sd = Math.sqrt( pixels.inject(0){|x| (x-mean)^2} / pixels.size)
      end
    end

  end

private

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x == 'labels.json'
    }.map{|x| (DATA_PATH + x)}
  end

end
