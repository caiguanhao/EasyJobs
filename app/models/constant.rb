class Constant < ActiveRecord::Base
  has_one :server
  validates_uniqueness_of :name
end
