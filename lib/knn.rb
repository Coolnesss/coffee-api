require 'rmagick'

class Knn

  include Magick

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'
  K = 3

  def classify(image)
    image = ImageList.new("lib/training_data/kahvi2.jpg").minify

    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x == 'labels.json'
    }.map{|x| (DATA_PATH + x)}
    images = ImageList.new(*image_names).to_a.map(&:minify)
    labels = JSON.parse IO.read(LABEL_PATH)
    distances = images.to_a.map{|x| Knn.distance(image, x) }
    sorted = distances.sort
    sorted_indexes = distances.map{|e| sorted.index(e)}
    nearest_labels = sorted_indexes[0..K-1].map{|x| labels[image_names[x].gsub("lib/training_data/","")]}

    #return the most common label
    nearest_labels.group_by(&:itself).values.max_by(&:size).first
    # Tähän <distance, label> parit ja sitte vaa sort ja majority
    # distance_pairs =

  end

  # Assume preprosessed, same amount of pixels
  def self.distance(image, other)
    raise ArgumentError, "Different size images" if image.columns != other.columns or image.rows != other.rows
    x = other.rows
    y = other.columns

    dist = 0
    y.times do |i|
      x.times do |j|
        dist += Math.sqrt(((other.pixel_color(i,j).red & 255) - (image.pixel_color(i,j).red & 255))**2)
      end
    end
    dist
  end
end
