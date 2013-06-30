class Server < ActiveRecord::Base
  has_many :jobs
  validates_presence_of :name, :host, :username
end
