class Interpreter < ActiveRecord::Base
  has_one :job
  validates_uniqueness_of :path
end
