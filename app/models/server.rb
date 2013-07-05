class Server < ActiveRecord::Base
  has_many :jobs
  belongs_to :constant
  validates_presence_of :name, :host, :username
  validates_uniqueness_of :name
end
