require 'rails_helper'
include Magick
include CoffeeStates

describe "Measuring accuracy using" do

  $LOO_error_rate = 0
  $LOO_error = 0
  $tfold_error_rate = 0
  $tfold_error = 0

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/labels.json'
  IMAGE_NAMES = Dir.entries(DATA_PATH).reject{ |x|
    x == '.' or x == '..' or x == 'labels.json'
  }.map{|x| (DATA_PATH + x)}
  LABELS = JSON.parse IO.read(LABEL_PATH)

  it "leave-one-out cross-validation", fast: false do
    n_misclass = 0
    IMAGE_NAMES.each do |test_image_name|
      image = Magick::Image.read(test_image_name).first.minify
      predicted = Knn.new.classify(image, IMAGE_NAMES.reject{|x| x == test_image_name})
      true_value = LABELS[test_image_name.split("/").last]
      #puts "#{predicted} vs #{true_value}"

      if predicted != true_value
        n_misclass += 1
        # weighted error
        $LOO_error += (CoffeeStates.const_get(predicted) - CoffeeStates.const_get(true_value)).abs
      end
    end
    $LOO_error_rate = n_misclass.to_f / IMAGE_NAMES.size.to_f
    $LOO_error /= IMAGE_NAMES.size.to_f
  end

  it "2-fold cross-validation", fast: true do
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
        $tfold_error += (CoffeeStates.const_get(predicted) - CoffeeStates.const_get(true_value)).abs
      end
      $tfold_error_rate = n_misclass.to_f / test_data.size.to_f
      $tfold_error /= test_data.size.to_f
    end

  end

  #cross-validating the zero-one error with leave one out -teqhinque and special-error
  after :all do
    puts
    puts "error rate for leave-one-out #{$LOO_error_rate}"
    puts "weighted error for leave-one-out #{$LOO_error}"
    puts "error rate for leave-one-out #{$tfold_error_rate}"
    puts "weighted error for leave-one-out #{$tfold_error}"

  end
end
