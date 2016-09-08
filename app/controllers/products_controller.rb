class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]
  
  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    @current_order = 0
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
    @current_order = 0
    if @product.uploaded_images
      @product.uploaded_images.each do |key, value|
        if value == ""
          @current_order = key
        end
      end
    end
  end

  # POST /products
  # POST /products.json
  def create

    @product = Product.new(product_params)
    remove_images
    
    respond_to do |format|
      if @product.save
        if params[:remove] == '1'
          format.html { redirect_to edit_product_path(@product) }
        else
          format.html { redirect_to @product, notice: 'Product was successfully created.' }
          format.json { render :show, status: :created, location: @product }
        end
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    remove_images
    respond_to do |format|
      if @product.update(product_params)
        if params[:remove] == '1'
          format.html { redirect_to edit_product_path(@product) }
        else
          format.html { redirect_to @product, notice: 'Product was successfully updated.' }
          format.json { render :show, status: :ok, location: @product }
        end
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :price, :description, :location, :uploaded_images)
    end

    def remove_images
      @product.uploaded_images = {}
      remove_index = -1;
      if params[:product][:uploaded_images]
        params[:product][:uploaded_images].each do |key, value|
          remove_index += 1
          if (key.to_i !=  remove_index)
            break
          end
          @product.uploaded_images[key] = value
        end
      end 
      if (remove_index != -1)
        params[:product][:uploaded_images].each do |key, value|
          if key.to_i > remove_index
            @product.uploaded_images[key.to_i - 1] = value
          end
        end
      end
    end
    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
