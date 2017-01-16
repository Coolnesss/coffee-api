require 'rubygems'
require 'ai4r'
include Ai4r::Data
include Ai4r::Clusterers

class Cluster

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'
  UNLABELLED_PATH = 'lib/unlabelled_training_data/'

  # Used to select first exemplars
  LABELS = JSON.parse(IO.read(LABEL_PATH))

  def train

    data = (all_training_names + unlabelled_training_names).map{|image_name| MiniMagick::Image.new(image_name).get_pixels}
    labels = all_training_names.map{|x| LABELS[x.split("/").last]}
    data_set = DataSet.new(:data_items => data)
    amt = LABELS.to_a.uniq{|filename, label| label}.size
    clusterer = KMeans.new.build(data_set, 5)

    clusterer.clusters.each_with_index do |cluster, index|
    	puts "Group #{index+1}"
    	p cluster.data_items.map{|x| [(all_training_names + unlabelled_training_names)[data.index(x)].split("/").last]}
    end
    binding.pry
  end

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x == 'labels.json'
    }.map{|x| (DATA_PATH + x)}
  end

  def unlabelled_training_names
    image_names = Dir.entries(UNLABELLED_PATH).reject{ |x|
      x == '.' or x == '..'
    }.map{|x| (UNLABELLED_PATH + x)}
  end


end
