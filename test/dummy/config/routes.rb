Rails.application.routes.draw do

  resources :houses do
    resources :dogs
    resources :cats do
      resources :parasites
    end
  end

  root to: redirect('/houses')

end
