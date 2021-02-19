Rails.application.routes.draw do
  root to: 'products#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :products, only: [:index, :import] do
    collection do
      get :index
      post :import
    end
  end
end
