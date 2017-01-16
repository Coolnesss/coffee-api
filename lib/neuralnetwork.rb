class Neuralnetwork
  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/regression_labels.json'
  LABELS = JSON.parse(IO.read(LABEL_PATH))

  def initialize(params = {})
    if (params[:training_data])
      train params[:training_data]
    else
      train
    end
  end

  def self.kek
    require 'benchmark'

    times = Benchmark.measure do

      srand 1

      net = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 1])

      puts "Training the network, please wait."
      2001.times do |i|
        net.train([0,0], [0])
        net.train([0,1], [1])
        net.train([1,0], [1])
        error = net.train([1,1], [0])
        puts "Error after iteration #{i}:\t#{error}" if i%200 == 0
      end

      puts "Test data"
      puts "[0,0] = > #{net.eval([0,0]).inspect}"
      puts "[0,1] = > #{net.eval([0,1]).inspect}"
      puts "[1,0] = > #{net.eval([1,0]).inspect}"
      puts "[1,1] = > #{net.eval([1,1]).inspect}"
    end

    puts "Elapsed time: #{times}"
  end

  def train(train_image_names=all_training_names)
    data = train_image_names.map{|image_name| MiniMagick::Image.new(image_name).get_good_pixels}
    labels = train_image_names.map{|x| LABELS[x.split("/").last]}

    #data = data.map.with_index{|x,i| x << labels[i]}
    data_set = Ai4r::Data::DataSet.new(data_items: data)
    @model = Ai4r::NeuralNetwork::Backpropagation.new([20, 10, 1])

    2000.times do |j|
      error = 0
      data.size.times do |i|
        error = @model.train(data[i], [labels[i]])
      end
      puts "Error #{error}" if j % 500 == 0

      ans = @model.eval(data[0])
      ans2 = @model.eval(data[1])
      ans3 = @model.eval(data[2])
      ans4 = @model.eval(data[3])

      puts "After #{j} iterations, ans: #{ans}, should be around #{labels[0]}" if j % 500 == 0
      puts "After #{j} iterations, ans: #{ans2}, should be around #{labels[1]}" if j % 500 == 0
      puts "After #{j} iterations, ans: #{ans3}, should be around #{labels[2]}" if j % 500 == 0
      puts "After #{j} iterations, ans: #{ans4}, should be around #{labels[3]}" if j % 500 == 0
    end
    binding.pry
  end

  def classify(image_path)
    @model.eval(MiniMagick::Image.new(image_path).get_pixels)
  end

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x.include? 'json' or x.include? "dark"
    }.map{|x| (DATA_PATH + x)}
  end

end
