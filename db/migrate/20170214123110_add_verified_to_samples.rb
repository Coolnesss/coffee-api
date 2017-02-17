class AddVerifiedToSamples < ActiveRecord::Migration[5.0]
  def change
    add_column :samples, :verified, :boolean
  end
end
