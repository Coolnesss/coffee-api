require 'libsvm'

class Svm

  attr_reader :problem, :parameter

  include Libsvm

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'

  def initialize(params = {})
    @problem = Problem.new
    @parameter = SvmParameter.new
    @parameter.cache_size = 50 # in megabytes
    @parameter.eps = (params[:eps] or 0.001)
    @parameter.c = (params[:c] or 10)
    @parameter.degree      = 3
    @parameter.gamma       = 0.1

    @parameter.kernel_type = (params[:kernel_type] or KernelType.const_get(:LINEAR))

    if params[:training_data] then @model = train(params[:training_data]) else @model = train end
  end

  def classify(image_path)
    image = MiniMagick::Image.open(image_path)
    pred = @model.predict(Node.features(image.get_pixels))
  end

  def train(train_image_names = all_training_names)
    images = train_image_names.map{|image_name| MiniMagick::Image.new(image_name)}
    labels = JSON.parse(IO.read(LABEL_PATH))
    label_names = approve(labels, train_image_names.map{|x| x.split("/").last}).values

    labels = CoffeeStates.encode label_names
    matrix = images.map{|x| x.get_pixels}
    examples = matrix.map {|ary| Node.features(ary) }
    @problem.set_examples(labels, examples)
    Libsvm::Model.train(@problem, @parameter)
  end

  private

    def approve(hash, arr)
      take_away = hash.keys.reject{|x| arr.include? x}
      hash.except *take_away
    end

    def all_training_names
      image_names = Dir.entries(DATA_PATH).reject{ |x|
        x == '.' or x == '..' or x == 'labels.json'
      }.map{|x| (DATA_PATH + x)}
    end

end
