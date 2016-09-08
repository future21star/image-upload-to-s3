json.extract! product, :id, :name, :price, :description, :location, :uploaded_images, :created_at, :updated_at
json.url product_url(product, format: :json)