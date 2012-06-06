class Cat < ActiveRecord::Base
  belongs_to :house
  has_many :parasites
  attr_accessible :name
end
