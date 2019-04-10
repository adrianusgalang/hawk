Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # resources :dashboard, only: [] do
  #   collection do
  #     get :summary
  #     get :getredash
  #   end
  # end

  get "/dashboard/summary" => "dashboard#summary"
  get "/dashboard/get-redash" => "dashboard#summary"

  # resources :metric, only: [] do
  #   collection do
  #     post :update_all
  #     post :create
  #     get :manage
  #     get :new
  #     get :checknewdimension
  #   end

  #   member do
  #     get :statistic
  #     post :update_threshold
  #     post :update
  #     post :delete
  #     get :edit
  #     get :on_off
  #   end
  # end

  post "/metric/update-all" => "metric#update_all"
  post "/metric/create" => "metric#create"
  get "/metric/manage" => "metric#manage"
  get "/metric/new" => "metric#new"
  get "/metric/check-new-dimension" => "metric#checknewdimension"

  get "/metric/:id/statistic" => "metric#statistic"
  post "/metric/:id/update-threshold" => "metric#update_threshold"
  post "/metric/:id/update" => "metric#update"
  post "/metric/:id/delete" => "metric#delete"
  get "/metric/:id/edit" => "metric#edit"
  get "/metric/:id/on-off" => "metric#on_off"
  get "/metric/:id/run-in-five-minutes" => "metric#runinfiveminutes"

  resources :healthz

  # resources :alert, only: [] do
  #   collection do
  #     get :index
  #     post :confirmuser
  #     get :test_tele
  #   end
  # end

  get "/alert" => "alert#index"
  post "/alert/confirm-user" => "alert#confirmuser"
  get "/alert/test-tele" => "alert#test_tele"

  # resources :date_exclude, only: [] do
  #   collection do
  #     get :index
  #     post :removedateexclude
  #   end
  # end

  get "/date-exclude" => "date_exclude#index"
  post "/date-exclude/remove-date-exclude" => "date_exclude#removedateexclude"

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

  # resources :channel, only: [] do
  #   collection do
  #     get :index
  #     post :broadcast
  #   end
  # end

  get "/channel" => "channel#index"
  post "/channel/broadcast" => "channel#broadcast"

  # get  "/cekcek" => "metric#testroute"
end
