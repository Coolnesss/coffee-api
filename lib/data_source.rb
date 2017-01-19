class DataSource

  include Singleton

  def initialize
    @data = {}
    Sample.all.each do |sample|
      sample_url = [sample.image.url, sample.image.path].max_by(&:length)
      sample_url = "https:" + sample_url if Rails.env.development? or Rails.env.production?
      @data[sample.id] = MiniMagick::Image.open(sample_url).get_good_pixels
    end
  end

  def fetch_data_and_labels(image_ids)
    [image_ids.map{|id| @data[id]}, image_ids.map{|id| Sample.find(id).label}]
  end

  def all_training_data
    fetch_data_and_labels Sample.ids
  end
end
