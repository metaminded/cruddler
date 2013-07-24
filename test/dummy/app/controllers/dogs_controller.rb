
class DogsController < ApplicationController
  cruddler :all,
    nested: 'house',
    nested_as: 'ref',
    after_create_path: ->(){ house_dogs_path(@house) },
    after_update_path: ->(){ house_dogs_path(@house) },
    after_destroy_path: ->(){ house_dogs_path(@house) } do |variable|
      params.required(:dog).permit(:name)

    end
end
