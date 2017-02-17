class AddDefaultValueToVerified < ActiveRecord::Migration[5.0]
  def change
    change_column :samples, :verified, :boolean, :default => false
  end
end
