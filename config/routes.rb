Gamesite::Application.routes.draw do
  root 'welcome#index'
  get '/rom_info', to: 'rom_info#show'
  get '/rom_map', to: 'rom_map#show'
  get '/ram_map', to: 'ram_map#show'
  get '/address/:addr', to: 'address#show'
end
