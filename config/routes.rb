Rails.application.routes.draw do
  resources :products
  root :to => 'products#index'

  post '/s3/signatureHandler' => 's3#signatureHandler'
  post '/s3/uploadSuccessful' => 's3#uploadSuccessful'
  delete '/s3/fileHandler/:id(.:format)', :to => 's3#fileHandler'
  get '/s3/initImage' => 's3#initImage'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
