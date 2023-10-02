Rails.application.routes.draw do
  root "static_pages#home"
  get "static_pages/home"

  devise_for :users, controllers: { registrations: 'custom_registrations' }

  resources :products

  get "/login", to: "session#new"
  post "/login", to: "session#create"
  delete "/logout", to: "session#destroy"

  resources :cart, only: :index

  get "add_to_cart", to: "cart#add_to_cart"
  get "increase_to_cart", to: "cart#increase_quantity_cart"
  get "decrease_to_cart", to: "cart#decrease_quantity_cart"
  get "remove_to_cart", to: "cart#remove_to_cart"

  resources :orders do
    patch "cancel", to: "orders#cancel"
  end

  resources :feedbacks

  namespace :admin do
    resources :orders, only: :index do
      patch "confirm", to: "orders#confirm"
      patch "cancel", to: "orders#cancel"
      get "reason", to: "orders#reason"
    end

    resources :products
  end
end
