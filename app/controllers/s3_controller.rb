require 'base64'
require 'openssl'
require 'digest/sha1'
class S3Controller < ApplicationController

skip_before_filter :verify_authenticity_token  

  def signatureHandler
    policy = Base64.encode64(set_policy_document.to_json).gsub("\n", "")
    signature = Base64.encode64(
        OpenSSL::HMAC.digest(
            OpenSSL::Digest.new('sha1'), 
            "fIcQrYK4iTL4G6jZvcQs5tzcEYSy6lTpt1rU1Br+", policy)
        ).gsub("\n","")
    render :json => {:policy => policy, :signature => signature}
  end

  def uploadSuccessful
    param = params
    render status: 200, json: {:name => params[:name], :uuid => params[:uuid], :key => params[:key] }
  end

  def blank
  end

  def initImage
    pa = params
    product = Product.find(params[:id])
    image_array = []
    product.uploaded_images.each do |key, value|
      value[:s3Key] = "AKIAJVGIQXZQUVKXBFVA"
      value[:s3Bucket] = "gv-images"
      value[:thumbnailUrl] = "https://gv-images.s3.amazonaws.com/" + value["key"]
      image_array << value
    end
    render status: 200, json: image_array.to_json
  end

  def fileHandler
    delete_params = params
    render status: 200, json: params.to_json
  end
private
  def set_policy_document
    policy_document = {}
    policy_document[:expiration] = params[:expiration]
    conditions = params[:conditions]
    policy_document[:conditions] = []
    policy_document[:conditions] << {"acl" => conditions[0][:acl]}
    policy_document[:conditions] << {"bucket" => conditions[1][:bucket]}
    policy_document[:conditions] << {"Content-Type" => conditions[2]["Content-Type"]}
    policy_document[:conditions] << {"success_action_status" => conditions[3][:success_action_status]}
    policy_document[:conditions] << {"key" => conditions[4][:key]} 
    policy_document[:conditions] << {"x-amz-meta-category" => conditions[5]["x-amz-meta-category"]}
    policy_document[:conditions] << {"x-amz-meta-qqfilename" => conditions[6]["x-amz-meta-qqfilename"]}
    policy_document[:conditions] << conditions[7]
    return policy_document
  end
end
