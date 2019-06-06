Rails.application.routes.draw do
  root 'pages#index'

  get "/summary",to: "pages#summary"
end
