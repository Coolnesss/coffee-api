class AddAttachmentImageToSamples < ActiveRecord::Migration
  def self.up
    change_table :samples do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :samples, :image
  end
end
