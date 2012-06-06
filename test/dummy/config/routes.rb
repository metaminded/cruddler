Rails.application.routes.draw do


  resources :houses do
    resources :dogs
    resources :cats do
      resources :parasites
    end
  end

end
