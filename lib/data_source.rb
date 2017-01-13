class DataSource

  include Singleton

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/regression_labels.json'
  LABELS = JSON.parse(IO.read(LABEL_PATH))

  def initialize
    @data = {}
    image_data = all_training_names.map{|name| MiniMagick::Image.new(name).get_good_pixels}
    all_training_names.each_with_index do |name, index|
      @data[name] = image_data[index]
    end
  end

  def fetch_data_and_labels(image_names)
    [image_names.map{|name| @data[name]}, image_names.map{|name| LABELS[name.split("/").last]}]
  end

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x.include? 'json'
    }.map{|x| (DATA_PATH + x)}
  end
end
