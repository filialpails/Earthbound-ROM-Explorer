Rails.application.routes.draw do
  root 'rom_info#index'
  resources :rom_info, only: [:index]
  resources :rom_map, only: [:index]
  resources :ram_map, only: [:index]
  resources :address, only: [:show]
end
