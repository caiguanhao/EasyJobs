class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate, :set_locale

  helper_method :active_action?
  def active_action?(array)
    array.include?(params[:action]) ? " active" : ""
  end

  private
    def authenticate
      redirect_to(new_admin_session_path) and return unless admin_signed_in?
    end

    def authenticate_with_token
      render nothing: true, status: 401 and return unless admin_signed_in?
    end

    def set_locale
      if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
        cookies['locale'] = { :value => params[:locale], :expires => 1.year.from_now }
        I18n.locale = params[:locale].to_sym
      elsif cookies['locale'] && I18n.available_locales.include?(cookies['locale'].to_sym)
        I18n.locale = cookies['locale'].to_sym
      end
    end

    def create_job_with(job_params)
      @job = Job.new(job_params)

      respond_to do |format|
        if @job.save
          format.html { redirect_to @job, notice: t('notice.job.created') }
        else
          format.html { render action: 'new' }
        end
      end
    end
end
