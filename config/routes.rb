Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  # root "articles#index"
  get "api/payments", to: "api/payments#index"
  get "api/payments/:id", to: "api/payments#show"
  post "api/payments", to: "api/payments#create"
  patch "/api/payments/:id", to: "api/payments#update"
  delete "/api/payments/:id", to: "api/payments#delete"

  get "api/deals", to: "api/deals#index"
  get "api/deals/:id", to: "api/deals#show"
  post "api/deals", to: "api/deals#create"
  patch "api/deals/:id", to: "api/deals#update"
  delete "api/deals/:id", to: "api/deals#delete"

  get "api/deals/:deal_id/payment_schedule", to: "api/payment_schedule#show"
  post "api/deals/:deal_id/payment_schedule", to: "api/payment_schedule#create"
  patch "api/deals/:deal_id/payment_schedule", to: "api/payment_schedule#update"
  delete "api/deals/:deal_id/payment_schedule", to: "api/payment_schedule#delete"

  post "/api/payments/:id/pay", to: "api/payments#pay"
end
