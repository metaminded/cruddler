DummyApp::Application.routes.draw do
  namespace :admin do
    resources :products
    resources :vendors
  end
end
