class Parasite < ActiveRecord::Base
  belongs_to :cat
  attr_accessible :legs, :name
end
