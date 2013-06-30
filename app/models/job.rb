class Job < ActiveRecord::Base
  belongs_to :server
  belongs_to :interpreter
  validates_presence_of :name, :script
end
