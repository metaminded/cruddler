class House < ActiveRecord::Base
  attr_accessible :name, :number

  has_many :dogs, as: 'ref'
  has_many :cats
end
