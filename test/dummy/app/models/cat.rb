class Cat < ActiveRecord::Base
  belongs_to :house
  attr_accessible :name
end
