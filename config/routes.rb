Rails.application.routes.draw do
  root 'rom_info#show'
  get '/rom_info', to: 'rom_info#show'
  get '/rom_map', to: 'rom_map#show'
  get '/ram_map', to: 'ram_map#show'
  get '/address/:address', to: 'address#show'
end
