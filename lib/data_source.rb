class DataSource

  #include Singleton

  def initialize(which_pixels)
    @data = {}
    Sample.where(verified: true).each do |sample|
      #sample_url = [sample.image.url, sample.image.path].max_by(&:length)
      sample_url = sample.image.path
      sample_url = "https:" + sample.image.url if Rails.env.production?
      @data[sample.id] = MiniMagick::Image.open(sample_url).send(which_pixels)
    end
  end

  def good_pixels_of_image(image_path)
    return MiniMagick::Image.open(sample_url).get_good_pixels if Rails.env.production?
  end

  def fetch_data_and_labels(image_ids)
    [image_ids.map{|id| @data[id]}, image_ids.map{|id| Sample.find(id).label}]
  end

  def all_training_data
    fetch_data_and_labels Sample.ids
  end
end
