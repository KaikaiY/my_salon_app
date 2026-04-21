Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  root 'home#index'
  resources :companies
  resources :therapist_profiles, except: :destroy
  resources :treatment_days, except: :destroy do
    patch :cancel, on: :member
    patch :reopen, on: :member

    resources :time_slots, only: %i[new create edit update destroy] do
      resources :reservations, only: %i[new create]
    end
  end
  resources :time_slots, only: %i[index]
  resources :reservations, only: %i[index show] do
    patch :cancel, on: :member
  end
  resources :invitations, only: %i[index new create] do
    patch :approve, on: :member
    get :send_email_confirmation, on: :member
    post :send_email, on: :member
  end
end
