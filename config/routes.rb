EasyJobs::Application.routes.draw do
  devise_for :admins, :controllers => { :sessions => "sessions" }

  resources :servers do
    member do
      get :delete
      post :create_blank_job, as: "create_blank_job_for"
    end
  end

  resources :jobs do
    member do
      get :run
      get :timestats
      delete :timestats, to: "jobs#destroy_timestats"
      get :delete
    end
  end

  resources :admins do
    member do
      get :delete
      post :edit
    end
  end

  get '/settings', to: "settings#index"
  scope '/settings' do
    put :edit_interpreters, to: "settings#update_interpreters"
    put :edit_constants, to: "settings#update_constants"
    get '/constant/:id', to: "settings#get_constant", as: "get_constant"
    put '/constant/:id', to: "settings#update_content_of_constant", as: "edit_content_of_constant"
  end

  root to: "jobs#index"

  namespace :api do
    namespace :v1 do
      get :help
      get :parameters
      delete :tokens, as: "revoke_token"
      resources :jobs, only: [:index, :show] do
        get :run
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
