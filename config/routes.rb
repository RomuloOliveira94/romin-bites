Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :restaurants, only: [ :index, :show ] do
        collection do
          post :import
          get :import_status
        end
        resources :menus, only: [ :index ]
      end
      resources :menus, only: [ :index, :show ] do
        resources :menu_items, only: [ :index ]
      end
      resources :menu_items, only: [ :index, :show ]
    end
  end
end
