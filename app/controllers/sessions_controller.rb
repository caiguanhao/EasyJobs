class SessionsController < Devise::SessionsController
  skip_before_action :authenticate
  layout 'application_small'
end
