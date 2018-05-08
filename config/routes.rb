Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :dashboard, only: [] do
    collection do
      get :summary
    end
  end

  resources :metric, only: [] do
    collection do
      post :update_all
      post :create
      get :manage
      get :new
    end

    member do
      get :statistic
      post :update_threshold
      post :update
      post :delete
      get :edit
    end
  end


end
