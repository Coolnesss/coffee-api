class NbDark

  include Singleton

  DATA_PATH = 'lib/training_data/'
  LABEL_PATH = 'lib/training_data/dark_labels.json'

  def initialize
    @model = Hash.new
    @priori = Hash.new(0)
    @observations = 0
    train
  end

  def classify(image_path)
    image = MiniMagick::Image.open image_path
    pixels = image.get_pixels

    max_score = -99999999999999
    best_label = ""

    @model.each do |label, distribution|
      score = Math.log(@priori[label] / @observations.to_f)

      distribution.each_with_index do |(mean, sd), index|
        next if sd == 0 or Rubystats::NormalDistribution.new(mean, sd).pdf(pixels[index]) == 0
        score += Math.log(Rubystats::NormalDistribution.new(mean, sd).pdf(pixels[index]))
      end

      if score > max_score
        max_score = score
        best_label = label
      end
    end
    best_label
  end


  def train(train_image_names=all_training_names)
    @model = {}
    @observations = 0
    @priori = Hash.new(0)

    images = train_image_names.map{|x| MiniMagick::Image.new(x)}
    labels = JSON.parse IO.read(LABEL_PATH)
    image_pixels = images.map(&:get_pixels)
    labels_in_training_data = train_image_names.map{|x| labels[x.split("/").last]}

    @observations = train_image_names.size

    train_image_names.each do |image_name|
      label = labels[image_name.split("/").last]
      @priori[label] += 1
      @model[label] = Array.new(image_pixels.first.size) { [0,0] } unless @model[label]
    end

    image_pixels.size.times do |i|
      image = images[i]
      pixels = image_pixels[i]
      label = labels[image.path.split("/").last]
      pixels.size.times do |j|
        # Sum the values
        @model[label][j][0] += pixels[j]
      end
    end

    # Find means
    @model.each do |k,v|
      amt = labels_in_training_data.select{|label| label == k}.size
      @model[k] = v.map{|x| [x[0] / amt.to_f, 0]}
    end

    # SD
    image_pixels.size.times do |i|
      image = images[i]
      pixels = image_pixels[i]
      label = labels[image.path.split("/").last]

      pixels.size.times do |j|
        @model[label][j][1] += (pixels[j] - @model[label][j][0])**2
      end
    end

    # SD
    @model.each do |k,v|
      amt = labels_in_training_data.select{|x| x == k}.size
      @model[k] = v.map{|x| [x[0], Math.sqrt(x[1] / amt.to_f)]}
    end
  end

private

  def all_training_names
    image_names = Dir.entries(DATA_PATH).reject{ |x|
      x == '.' or x == '..' or x.include? 'json'
    }.map{|x| (DATA_PATH + x)}
  end

end
