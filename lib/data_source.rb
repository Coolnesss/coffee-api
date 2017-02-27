class DataSource

  include Singleton

  def initialize
    @data = {}
    Sample.where(verified: true).each do |sample|
      #sample_url = [sample.image.url, sample.image.path].max_by(&:length)
      sample_url = sample.image.path
      sample_url = "https:" + sample.image.url if Rails.env.production?
      @data[sample.id] = MiniMagick::Image.open(sample_url).get_pixels
    end
  end

  def good_pixels_of_image(image_path)
    return MiniMagick::Image.open(sample_url).get_good_pixels if Rails.env.production?
  end

  # which_pixels takes :dark or :good
  def fetch_data_and_labels(image_ids, which_pixels = :good)
    case which_pixels
      when :good
        [image_ids.map{|id| good_pixels(@data[id])}, image_ids.map{|id| Sample.find(id).label}]
      when :dark
        [image_ids.map{|id| dark_pixels(@data[id])}, image_ids.map{|id| Sample.find(id).label}]
    end
  end

  def all_training_data(which_pixels = :good)
    fetch_data_and_labels Sample.ids, which_pixels
  end

  private

  def dark_pixels(image)
    #selecting every 10th row a little to the right from the coffee pan
    pixels = (3300..(400*400)).step(10*400).to_a
    pixels.map{|x| image[x]}
  end

  def good_pixels(image)
    good_pixels = [87311,95716,102082,89321,99481,101280,127705,116098,101682,95316,102080,119714,87711,144209,87712,116498,128107,144936,113372,102130]
    good_pixels.map do |x|
      (image[x-1] + image[x] + image[x-2]
      + image[x - 1 - 400] +  image[x - 400] + image[x - 2 - 400]
      + image[x - 1 + 400] +  image[x + 400] + image[x - 2 + 400]) / 9.0
    end
  end
end
