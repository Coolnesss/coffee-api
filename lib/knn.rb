require 'rmagick'

class Knn

  include Magick

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'
  K = 3

  def classify(image, train_image_names = all_training_names)
    images = ImageList.new(*train_image_names).to_a.map(&:minify)
    labels = JSON.parse IO.read(LABEL_PATH)
    distances = images.to_a.map{|x| Knn.distance(image, x) }
    sorted = distances.sort
    sorted_indexes = sorted.map{|e| distances.index(e)}
    nearest_labels = sorted_indexes[0..K-1].map{|x| labels[train_image_names[x].gsub("lib/training_data/","")]}

    #return the most common label
    nearest_labels.group_by(&:itself).values.max_by(&:size).first
  end

  # Assume preprosessed, same amount of pixels
  def self.distance(image, other)
    raise ArgumentError, "Different size images" if image.columns != other.columns or image.rows != other.rows
    xstart = 58
    xend = 215
    y = other.columns
    imagepixels = image.get_pixels(0,xstart, 200, xend-xstart).map{|p| [p.red, p.green, p.blue]}
    otherpixels = other.get_pixels(0,xstart, 200, xend-xstart).map{|p| [p.red, p.green, p.blue]}

    dist = 0
    imagepixels.size.times do |i|
      dist += Math.sqrt( ((imagepixels[i].sum / 3.0) - (otherpixels[i].sum / 3.0))**2)
    end
    dist
  end

  private

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x == 'labels.json'
    }.map{|x| (DATA_PATH + x)}
  end
end
