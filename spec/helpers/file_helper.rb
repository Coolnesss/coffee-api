require 'spec_helper'

DATA_PATH = 'lib/training_data/'
LABEL_PATH = 'lib/training_data/labels.json'
REGRESSION_LABELS_PATH = 'lib/training_data/regression_labels.json'
IMAGE_NAMES = Dir.entries(DATA_PATH).reject{ |x|
  x == '.' or x == '..' or x.include? '.json'
}.map{|x| (DATA_PATH + x)}
LABELS = JSON.parse IO.read(LABEL_PATH)
REGRESSION_LABELS = JSON.parse IO.read(REGRESSION_LABELS_PATH)


def add_train_data_to_db
  IMAGE_NAMES.reject{|name| name.include? "dark"}.each do |name|
    Sample.create image: File.open(name), label: REGRESSION_LABELS[name.split("/").last]
  end
end
