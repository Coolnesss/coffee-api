class Id3

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'
  # Used to select first exemplars
  LABELS = JSON.parse(IO.read(LABEL_PATH))

  def initialize(params = {})
    if (params[:training_data])
      train params[:training_data]
    else
      train
    end
  end

  def train(train_image_names=all_training_names)
    data = train_image_names.map{|image_name| MiniMagick::Image.new(image_name).get_pixels}
    labels = train_image_names.map{|x| LABELS[x.split("/").last]}

    data = data.map.with_index{|x,i| x << labels[i]}
    data_set = Ai4r::Data::DataSet.new(data_items: data)
    @model = Ai4r::Classifiers::ID3.new.build(data_set)
    binding.pry
  end

  def classify(image_path)
    @model.eval(MiniMagick::Image.new(image_path).get_pixels)
  end

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x == 'labels.json'
    }.map{|x| (DATA_PATH + x)}
  end

end
