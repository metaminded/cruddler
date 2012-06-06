
class ParasitesController < ApplicationController
  cruddler :all,
    nested: ['house', 'cat'],
    index_path: ->(){ house_cat_parasites_path(@house, @cat) }

end
