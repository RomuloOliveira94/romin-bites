Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :restaurants, only: [ :index ]
      resources :menus, only: [ :index, :show ]
      resources :menu_items, only: [ :index, :show ]
    end
  end
end
