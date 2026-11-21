Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get    "login"  => "sessions#new"
  post   "login"  => "sessions#create"
  delete "logout" => "sessions#destroy"

  root "sheets#show"
  get "sheet" => "sheets#show", as: :sheet
  post "contributions/upsert" => "contributions#upsert", as: :upsert_contribution

  get   "cash" => "cash_records#show", as: :cash_record
  patch "cash" => "cash_records#update"
  resources :cash_entries, only: %i[create edit update destroy]

  resources :members, only: %i[index update destroy] do
    post :bulk_create, on: :collection
    patch :move, on: :member
  end
  post   "sections"     => "members#create_section",  as: :sections
  patch  "sections/:id" => "members#update_section",  as: :section
  delete "sections/:id" => "members#destroy_section"

  resources :offering_types, only: %i[index create update destroy]
  resource :settings, only: %i[edit update]
  get "backup" => "settings#backup", as: :backup
  resources :users, only: %i[index create destroy]
  get   "password" => "users#password", as: :password
  patch "password" => "users#update_password"
end
