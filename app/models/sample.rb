require "open-uri"

class Sample < ApplicationRecord

  has_attached_file :image
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates :label, presence: true

  def image_from_gurula
    self.image = open CoffeeState.const_get(:IMAGE_URL)
  end
end
