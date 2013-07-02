class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate

  helper_method :active_action?
  def active_action?(array)
    array.include?(params[:action]) ? " active" : ""
  end

  private
    def authenticate
      redirect_to(new_admin_session_path) and return unless admin_signed_in?
    end
end
