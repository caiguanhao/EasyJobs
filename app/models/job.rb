class Job < ActiveRecord::Base
  belongs_to :server
  belongs_to :interpreter
end
