Rails.application.routes.draw do
  root 'top#index' 
  get 'top/index', to: 'top#index'
  post 'callback', to: 'line_bot#callback'
end
