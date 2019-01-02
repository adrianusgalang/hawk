Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :dashboard, only: [] do
    collection do
      get :summary
      get :getredash
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
      get :on_off
    end
  end

  resources :healthz

  resources :alert, only: [] do
    collection do
      get :index
      post :confirmuser
      get :test_tele
    end
  end

  resources :date_exclude, only: [] do
    collection do
      get :index
      post :removedateexclude
    end
  end

  resources :list, only: [] do
    resources :metrics do
      get :all
      get :group
    end

    resources :alerts do
      get :all
      get :group
    end

    member do
      get :metric
      get :alert
    end
  end

end
