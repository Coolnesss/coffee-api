class KMeans

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'

  attr_reader :clusters, :data_names, :data, :K

  def initialize(params = {data: all_training_names})
    @data = params[:data].map{|image_name| MiniMagick::Image.new(image_name).get_pixels}
    @data_names = params[:data]
    @K = (params[:K] or 5)
    @clusters = Hash.new
  end

  def cluster
    previous_clustering = nil
    centroids = random_centroids

    while previous_clustering != @clusters
      previous_clustering = @clusters

      # Assign each data point to closest centroid
      @clusters = {}
      @data.each_with_index do |image_pixels, index|
        closest = centroids.index centroids.min_by{|centroid| distance(centroid, image_pixels)}
        (@clusters[closest] ||= []) << index
      end

      # Move centroids to match new points
      centroids = @clusters.map{|cluster, image_indices| mean(image_indices)}

      puts @clusters
    end
  end

  private

  # Mean image (vector) of a single cluster
  def mean(cluster)
    images = cluster.map{|image_index| @data[image_index]}
    mean_cluster = []
    image_length = images.first.size
    image_length.times do |i|
      mean_cluster << images.map{|row| row[i]}.sum / cluster.size.to_f
    end
    mean_cluster
  end

  def random_centroids
     @data.sample(@K)
  end

  def distance(first, second)
    first.zip(second).inject(0) do |sum, (x, y)|
      sum + euclidean_dist(x, y)
    end
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
