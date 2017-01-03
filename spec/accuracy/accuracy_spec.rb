require 'rails_helper'
require 'libsvm'

include CoffeeStates
include Libsvm


describe "Measuring accuracy using" do

  $LOO_error_rate = 0
  $LOO_error = 0
  $onefold_error_rate = 0
  $onefold_error = 0

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'
  IMAGE_NAMES = Dir.entries(DATA_PATH).reject{ |x|
    x == '.' or x == '..' or x == 'labels.json'
  }.map{|x| (DATA_PATH + x)}
  LABELS = JSON.parse IO.read(LABEL_PATH)

  it "k-fold cross-validation", slow: true do


    [:LINEAR, :POLY, :RBF, :SIGMOID].each do |type|

      c = 30
      eps = 0.0001
      svm = Svm.new training_data: IMAGE_NAMES, kernel_type: KernelType.const_get(type), c: c, eps: eps


      [23].each do |nfold|
        result          = Model.cross_validation(svm.problem, svm.parameter, nfold)
        predicted_name  = CoffeeStates.decode(result)
        correct_labels = IMAGE_NAMES.map{|x| LABELS[x.split("/").last]}
        correctness     = predicted_name.map.with_index { |p, i| p == correct_labels[i].to_sym }

        correct = correctness.select { |x| x }
        accuracy = correct.size.to_f / correctness.size
        acc_str = "%.2f" % accuracy
        puts "Accuracy[type = #{type}, nfold = #{nfold}] : #{acc_str}, eps: #{eps}, c: #{c}"
      end
    end

  end

  it "20% of random data as test data", fast: true do
    shuffled = IMAGE_NAMES.shuffle
    # 80-20 split
    split_point = (shuffled.size * 0.8).to_i
    training_data = shuffled.take split_point
    test_data = shuffled.drop split_point

    n_misclass = 0
    test_data.each do |test_image_name|
      image = Magick::Image.read(test_image_name).first.minify

      predicted = Knn.new.classify(image, training_data)
      true_value = LABELS[test_image_name.split("/").last]

      if predicted != true_value
        n_misclass += 1
        # weighted error
        $onefold_error += (CoffeeStates.const_get(predicted) - CoffeeStates.const_get(true_value)).abs
      end
      $onefold_error_rate = n_misclass.to_f / test_data.size.to_f
      $onefold_error /= test_data.size.to_f
    end

  end

  after :all do
    puts
    puts "error rate for leave-one-out #{$LOO_error_rate}"
    puts "weighted error for leave-one-out #{$LOO_error}"
    puts "error rate for one-fold #{$onefold_error_rate}"
    puts "weighted error for one-fold #{$onefold_error}"

  end
end
