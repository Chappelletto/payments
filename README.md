# README

Учебный проект для ведения платёжных расписаний. REST API

Crud - платежи и расписание, сделки + тесты
сериализация, валидация,
Тесты на Rspec
тесты валидатора
X-Auth-Token - аутетификация

api для платежей, сделок и платёжных расписаний

get "api/payments", to: "api/payments#index" <br>
get "api/payments/:id", to: "api/payments#show" <br>
post "api/payments", to: "api/payments#create" <br>
patch "api/payments/:id", to: "api/payments#update" <br>
delete "api/payments/:id", to: "api/payments#delete" <br>

get "api/deals", to: "api/deals#index" <br>
get "api/deals/:id", to: "api/deals#show" <br>
post "api/deals", to: "api/deals#create" <br>
patch "api/deals/:id", to: "api/deals#update" <br>
delete "api/deals/:id", to: "api/deals#delete" <br>

get "api/deals/:deal_id/payment_schedule", to: "api/payment_schedule#show" <br>
post "api/deals/:deal_id/payment_schedule", to: "api/payment_schedule#create" <br>
patch "api/deals/:deal_id/payment_schedule", to: "api/payment_schedule#update" <br>
delete "api/deals/:deal_id/payment_schedule", to: "api/payment_schedule#delete"

post "/api/payments/:id/pay", to: "api/payments#pay"
