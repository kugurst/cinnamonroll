Rails.application.routes.draw do
  get 'landing', to: 'static#landing'
  get 'about_me', to: 'static#about_me'

  get 'posts/:category/:file_path', to: 'posts#show', as: :post_cat
  get 'posts/:category/:file_path/comments', to: 'posts#comments', as: :post_comments

  Post::CATEGORIES.each do |c|
    get "#{c.to_s.pluralize}", to: 'posts#category', as: c.to_s.pluralize.to_sym
  end

  resources :comments
  # resources :posts
  get 'users/:id/confirm/:confirmation_token', to: 'users#confirm', as: :confirm_user
  resources :users

  post 'security/post_rsa_key', to: 'security#post_rsa_key'
  get 'security/get_aes_key', to: 'security#get_aes_key'

  get 'login', to: 'session#new'
  post 'login', to: 'session#create'
  delete 'logout', to: 'session#destroy'

  get 'comments/box/reply', to: 'comments#box', defaults: { type: :reply }
  get 'comments/box/new', to: 'comments#box', defaults: { type: :new }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static#landing'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
