class Dog < ActiveRecord::Base
  belongs_to :ref, polymorphic: true
end
