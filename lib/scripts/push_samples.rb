DATA_PATH = 'lib/training_data/'
LABEL_PATH = 'lib/training_data/regression_labels.json'
LABELS = JSON.parse(IO.read(LABEL_PATH))

def all_training_names
  image_names = Dir.entries(DATA_PATH).reject{ |x|
    x == '.' or x == '..' or x.include? 'json'
  }.map{|x| (DATA_PATH + x)}
end

training_names = all_training_names

training_names.each do |name|
  Sample.create image: File.open(name), label: LABELS[name.split("/").last]
end
