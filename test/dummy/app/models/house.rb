class House < ActiveRecord::Base

  has_many :dogs, as: 'ref'
  has_many :cats
end
