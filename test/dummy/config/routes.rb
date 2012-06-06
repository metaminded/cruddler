Rails.application.routes.draw do

  resources :houses do
    resources :dogs
    resources :cats
  end

end
