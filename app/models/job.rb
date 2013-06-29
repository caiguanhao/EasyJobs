class Job < ActiveRecord::Base
  Interpreters = ["/usr/bin/perl", "/usr/bin/php", "/usr/bin/python"]
  belongs_to :server
end
