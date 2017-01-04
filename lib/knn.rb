class Knn

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'
  K = 3
  XSTART = 58
  XEND = 215

  def classify(image_name, train_image_names = all_training_names)

    image = pixels_matrix(image_name).flatten
    images = train_image_names.map{|x| pixels_matrix(x).flatten}#ImageList.new(*train_image_names).to_a.map(&:minify)
    labels = JSON.parse IO.read(LABEL_PATH)
    distances = images.map{|x| distance(image, x) }
    sorted = distances.sort
    sorted_indexes = sorted.map{|e| distances.index(e)}
    nearest_labels = sorted_indexes[0, K]
      .map{|x| labels[train_image_names[x].split("/").last]}
    #return the most common label
    nearest_labels.group_by(&:itself).values.max_by(&:size).first
  end

  # Assume preprosessed, same amount of pixels
  def distance(image, other)
    dist = 0
    image.size.times do |i|
      dist += euclidean_dist(image[i], other[i])
    end
    dist
  end

  private

  def pixels_matrix(path)
    pixels = IO.read("|convert #{path} rgb:-").unpack 'C*'
    # reshape array according to image size
    # (although in reality I would use NArray or NMatrix)
    width = IO.read("|identify -format '%w' #{path}").to_i
    pixels.each_slice(width).to_a
  end

  def euclidean_dist(x, y)
    Math.sqrt((x - y)**2)
  end

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x == 'labels.json'
    }.map{|x| (DATA_PATH + x)}
  end
end
