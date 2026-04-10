Rails.application.routes.draw do
  
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  
  root "home#index"
  resources :companies
  resources :treatment_days, except: :destroy do
    resources :time_slots, only: %i[new create edit update] do
      resources :reservations, only: %i[new create]
    end
  end
  resources :time_slots, only: %i[index]
  resources :reservations, only: %i[index show]
  resources :invitations, only: %i[index new create] do
    patch :approve, on: :member
  end
end
