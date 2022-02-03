Rails.application.routes.draw do
  root 'top#index' 
  get 'top/index', to: 'top#index'
end
