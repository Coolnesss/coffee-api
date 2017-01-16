class CreateSamples < ActiveRecord::Migration[5.0]
  def change
    create_table :samples do |t|
      t.float :label

      t.timestamps
    end
  end
end
