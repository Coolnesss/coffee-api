require 'rmagick'
require 'libsvm'

class Svm

  attr_reader :problem, :parameter

  include Libsvm

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'

  XSTART = 58
  XEND = 215
  def initialize(params)
    @problem = Problem.new
    @parameter = SvmParameter.new
    @parameter.cache_size = 10 # in megabytes
    @parameter.eps = (params[:eps] or 0.001)
    @parameter.c = (params[:c] or 10)
    @parameter.degree      = 5
    @parameter.gamma       = 0.01

    @parameter.kernel_type = params[:kernel_type] or KernelType.const_get(:LINEAR)

    @model = train params[:training_data]
  end

  def classify(image_path)
    image = Svm.pixels_matrix image_path
    pred = @model.predict(Node.features(image.flatten))
  end

  def train(train_image_names = all_training_names)
    matrix=[]
    images = train_image_names.map{|x| Svm.pixels_matrix(x)}
    labels = JSON.parse(IO.read(LABEL_PATH))
    label_names = approve(labels, train_image_names.map{|x| x.split("/").last}).values

    labels = CoffeeStates.encode label_names
    matrix = images.map{|x| x.flatten}
    examples = matrix.map {|ary| Node.features(ary) }
    @problem.set_examples(labels, examples)
    Libsvm::Model.train(@problem, @parameter)
  end


    def self.pixels_matrix(path)
      pixels = IO.read("|convert #{path} gray:-").unpack 'C*'
      # reshape array according to image size
      # (although in reality I would use NArray or NMatrix)
      width = IO.read("|identify -format '%w' #{path}").to_i
      pixels.each_slice(width).to_a
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

    def relabel_one_vs_all(label, labels)
      result={}
      labels.map do |key,value|
        if value == label
          result[key] = 1
        else
          result[key] = -1
        end
      end
      result
    end

    def relabel_all(labels)
      relabelled={}
      labels.values.uniq.each do |label|
        relabelled[label]=relabel_one_vs_all(label, labels)
      end
      relabelled
    end

end
