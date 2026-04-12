Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'

  post '/conta',     to: 'accounts#create'
  get  '/conta',     to: 'accounts#show'
  post '/transacao', to: 'transactions#create'
end