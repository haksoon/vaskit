Rails.application.routes.draw do
  # HTTP RESETful
  # get: index, show, new, edit
  # post: create
  # put/patch: update -> put은 해당 자원 전체가 교체되는 것, patch는 해당 자원의 일부가 변경되는 것
  # delete: destroy

  resources :asks do
    member do
      get 'show_detail'
      post 'like'
    end
  end

  resources :ask_tmps, only: [:create]

  resources :votes, only: [:create, :destroy]

  resources :comments, only: [:index, :create, :update, :destroy] do
    member do
      post 'like'
    end
  end

  resources :preview_images, only: [:show, :create, :update]

  resources :deals, only: [] do
    collection do
      get 'get_naver_deals'
      post 'create_by_naver'
    end
  end

  resources :collections, only: [:index, :show]

  resources :videos, only: [:index, :show]

  resources :search, only: [:index] do
    collection do
      get 'keyword'
    end
  end

  resources :user_gcm_keys, only: [:create]

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  devise_scope :user do
    post 'users/facebook', to: 'users/facebook#auth'
    post 'users/sign_up', to: 'users/registrations#create'
    post 'users/check_email', to: 'users/registrations#check_email'

    get 'users/forgot_password', to: 'users/passwords#new'
    get 'users/reset_password', to: 'users/passwords#edit'

    get 'users/alarm_check', to: 'users/sessions#alarm_check'
    get 'users/get_user_profile', to: 'users/sessions#get_user_profile'
    get 'users/get_user_alarms', to: 'users/sessions#get_user_alarms'
    get 'users/get_my_recent_ask', to: 'users/sessions#get_my_recent_ask'

    get 'users/', to: 'users/sessions#users'
    get 'users/history', to: 'users/sessions#history'
    get 'users/settings', to: 'users/sessions#settings'

    get 'users/settings/edit_profile', to: 'users/sessions#edit_profile'
    delete 'users/destroy_user_picture', to: 'users/sessions#destroy_user_picture'
    put 'users/change_nickname', to: 'users/sessions#change_nickname'

    get 'users/settings/edit_password', to: 'users/sessions#edit_password'
    put 'users/change_password', to: 'users/sessions#update_password'

    get 'users/settings/edit_push_alarm', to: 'users/sessions#edit_push_alarm'
    get 'users/settings/edit_email_alarm', to: 'users/sessions#edit_email_alarm'
    put 'users/toggle_alarm_option', to: 'users/sessions#toggle_alarm_option'
  end

  resources :log_errors, only: [:create]
  resources :log_inquiries, only: [:create]
  resources :log_reports, only: [:create]

  resources :shares, only: [:new, :create]
  resources :share_logs, only: [:create]

  resources :alarms, only: [:index]

  resources :etc, only: [] do
    collection do
      get 'access_term'
      get 'privacy_policy'
      get 'contact_us'
      get 'faq_help'
    end
  end

  get 'landing', to: 'home#landing'
  get 'open_app', to: 'home#open_app'

  # Admin Page
  namespace :admin do
    get '/', to: 'home#index'
    post '/sign_in', to: 'home#create'
    delete '/sign_out', to: 'home#destroy'
    resources :asks, only: [:index, :show, :update]
    resources :events
    resources :collections
    resources :collection_keywords, only: [:index, :create]
    resources :collection_to_collection_keywords, only: [:index]
    resources :collection_to_asks, only: [:create]
    resources :videos
    resource :search_keywords, only: [:show, :create, :update, :destroy]
    resources :refer_links, except: [:delete]
    resources :notices, only: [:index, :new, :create] do
      collection do
        get 'target'
        get 'test'
      end
    end
    resources :tables, only: [:index] do
      get ':table_name', to: 'tables#index', on: :collection
    end
    resources :analysis, only: [:index]
  end

  # Templates
  get 'templates/faq_help', to: 'templates#faq_help'
  get 'templates/access_term', to: 'templates#access_term'
  get 'templates/privacy_policy', to: 'templates#privacy_policy'

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
