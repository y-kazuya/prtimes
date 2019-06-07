Rails.application.routes.draw do
  root 'pages#index'

  get "/summary",to: "pages#summary"
  get "/noshow",to: "pages#noshow"
end
