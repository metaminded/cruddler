
class CatsController < ApplicationController
  cruddler :all,
    nested: 'house',
    index_path: ->(){ house_cats_path(@house) }
end
