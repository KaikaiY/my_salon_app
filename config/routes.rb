Rails.application.routes.draw do
  
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  
  root "home#index"
  resources :companies
  resources :invitations, only: %i[index new create] do
    patch :approve, on: :member
  end
end
