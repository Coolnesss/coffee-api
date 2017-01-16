require "open-uri"

class Sample < ApplicationRecord

  has_attached_file :image,
  storage: :s3,
    s3_credentials: {
      bucket: ENV.fetch('S3_BUCKET_NAME'),
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
      s3_region: ENV.fetch('AWS_REGION'),
      :s3_host_name => 's3.eu-central-1.amazonaws.com'
    }

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def image_from_gurula
    self.image = open CoffeeState.const_get(:IMAGE_URL)
  end
end
