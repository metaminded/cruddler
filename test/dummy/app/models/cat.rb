class Cat < ActiveRecord::Base
  belongs_to :house
  has_many :parasites
end
