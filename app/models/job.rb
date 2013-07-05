class Job < ActiveRecord::Base
  belongs_to :server
  belongs_to :interpreter
  has_many :time_stats, dependent: :destroy
  validates_presence_of :name, :script
  validates_uniqueness_of :name
end
