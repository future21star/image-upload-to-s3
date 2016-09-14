class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :price
      t.string :description
      t.string :location
      t.json :uploaded_images

      t.timestamps
    end
  end
end
