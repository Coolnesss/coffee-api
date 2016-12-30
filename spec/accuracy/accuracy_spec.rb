require 'rails_helper'
include Magick
include CoffeeStates

describe "Accuracy measurement" do

  $error_rate = 0
  $error = 0

  it "is printed after all" do
    DATA_PATH = 'lib/training_data/'
    LABEL_PATH = 'lib/training_data/labels.json'

    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x == 'labels.json'
    }.map{|x| (DATA_PATH + x)}
    labels = JSON.parse IO.read(LABEL_PATH)
    n_misclass = 0
    image_names.each do |test_image_name|
      image = Magick::Image.read(test_image_name).first.minify
      predicted = Knn.new.classify(image, image_names.reject{|x| x == test_image_name})
      true_value = labels[test_image_name.split("/").last]
      puts "#{predicted} vs #{true_value}"

      if(predicted != true_value)
        n_misclass += 1
        #special error
        $error += (CoffeeStates.const_get(predicted) - CoffeeStates.const_get(true_value)).abs
      end
    end
    $error_rate = n_misclass.to_f / image_names.size.to_f
    $error /= image_names.size.to_f
  end

  #cross-validating the zero-one error with leave one out -teqhinque and special-error
  after :all do

    p "error rate #{$error_rate}"
    p "special error #{$error}"
  end
end
