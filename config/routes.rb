Rails.application.routes.draw do
  resources :asks do
    member do
      get 'ask_complete'
      get 'create_complete'
    end
  end
  resources :ask_completes
  resources :ask_deals
  resources :categories
  resources :comments do
    member do
      post 'like'
      delete 'comment_del'
    end
  end
  resources :comment_likes
  resources :deals do
    collection do
      get 'get_naver_deals'
      post 'create_by_naver'
    end
  end
  resources :hash_tags
  resources :notices
  resources :mail_logs
  resources :preview_images do
    collection do
      post 'create_by_naver'
    end
  end
  resources :share_logs
  devise_for :users, :controllers => {
    :sessions => 'users/sessions',
    :registrations => 'users/registrations',
    :passwords => 'users/passwords'
  }
  devise_scope :user do
    get 'users/facebook', :to => "users/facebook#auth"
    # get 'users/check_email', :to => "users/sessions#check_email"
    get 'users/check_email', :to => "users/registrations#check_email" #AJS추가
    get 'users/get_user_data', :to => "users/sessions#get_user_data" #AJS추가
    get 'users/alram_check', :to => "users/sessions#alram_check" #AJS추가
    # get 'users/manage', :to => "users/sessions#manage"
    put 'users/change_nickname', :to => "users/sessions#change_nickname"
    put 'users/toggle_receive_notice', :to => "users/sessions#toggle_receive_notice"
    delete 'users/:id', :to => "users/registrations#destroy"
  end
  resources :user_categories
  resources :visitors
  resources :votes
  resources :search do
    collection do
      get 'get_keyword'
    end
  end
  resources :home do
    collection do
      get 'show_detail'
      get 'set_category'
      get 'no_result'
    end
    member do
      post 'like'
    end
  end

  resources :inquiry

  get 'landing', :to => "etc#landing" #AJS추가 랜딩페이지 URL 변경
  resources :etc do
    collection do
      get 'landing'
      get 'access_term'
      get 'privacy_policy'
      get 'inquiry'
      post 'create_inquiry'
    end
  end


  resources :alrams do
    collection do
      put 'read'
      put 'all_read'
    end
  end
  resources :reports
  resources :rank_asks
  resources :admin do
    collection do
      post 'submit_rank_ask'
      delete 'delete_rank_ask'
      post 'create_notice'
    end
  end
  get "/admin/table/:table_name", :to => "admin#table"

  # get "/:string_id", :to => "etc#user"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

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
