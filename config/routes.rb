Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :dashboard, only: [] do
    collection do
      get :summary
    end
  end

  resources :metric, only: [] do
    member do
      get :statistic
    end
  end
end
