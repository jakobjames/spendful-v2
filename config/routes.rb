Spendful::Application.routes.draw do
  
  mount StripeEvent::Engine => '/stripe-webhook'
  
  scope "onboarding" do
    get "" => "onboarding#new", :as => "new_onboarding"
    post "step1" => "onboarding#step1", :as => "step1_onboarding"
    post "step2" => "onboarding#step2", :as => "step2_onboarding"
    post "finish" => "onboarding#finish", :as => "finish_onboarding"
  end
	
  resources :budgets do
    resources :transactions
    resources :items do
      resources :transactions
    end
  end
  
  post "feedback" => "feedback#create", :as => "feedback"
  
  scope "account" do
    resources :subscriptions
    post "payment" => "subscriptions#payment", :as => "subscription_payment"
    get     ""  => "users#edit",  :as => "account"
    put    ""  => "users#update",    :as => "account"
    delete  ""  => "users#destroy", :as => "account"
  end

	get "logout" => "sessions#destroy", :as => "logout"
	
  scope "login" do
    get   ""   =>  "sessions#new",     :as => "login"
    post  ""   =>  "sessions#create",  :as => "login"
    get   "password" => "passwords#new",     :as => "forgot_password"
    post  "password" => "passwords#create",  :as => "forgot_password"
    get   "password/reset(/:id)" => "passwords#show", :as => "reset_password"
    put   "password/reset(/:id)" => "passwords#update", :as => "reset_password"
  end

  get "signup" => "users#new", :as => "signup"
  post "signup" => "users#create", :as => "signup"
  
  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  match "/500", :to => "errors#internal_server_error"
  match "/404", :to => "errors#not_found", :as => 'not_found'

  root :to => "pages#index"

  match ":action", :controller => "pages"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
