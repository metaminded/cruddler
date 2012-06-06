class Dog < ActiveRecord::Base
  belongs_to :ref, polymorphic: true
  attr_accessible :name, :ref
end
