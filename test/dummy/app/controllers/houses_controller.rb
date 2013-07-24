
class HousesController < ApplicationController
  cruddler :all do
    params.required(:house).permit(:name, :number)
  end
end
