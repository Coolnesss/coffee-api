require 'ruby-spark'
require 'oj'
class ApacheLm

    DATA_PATH = 'lib/training_data/'
    LABEL_PATH = 'lib/training_data/regression_labels.json'
    LABELS = JSON.parse(IO.read(LABEL_PATH))
    include Spark::Mllib


  def train(train_image_names = all_training_names)

    Spark.start
    sc = Spark.sc

    raw_data = train_image_names.map{|image_name| MiniMagick::Image.new(image_name).get_good_pixels}
    data = train_image_names.map{|image_name| LabeledPoint.new(LABELS[image_name.split("/").last], MiniMagick::Image.new(image_name).get_good_pixels)}
    puts "done making data"
    binding.pry

    lrm = LassoWithSGD.train(sc.parallelize(data))
    p lrm.predict(raw_data.first)

    binding.pry
  end

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x.include? 'json' or x.include? "dark"
    }.map{|x| (DATA_PATH + x)}
  end


end
