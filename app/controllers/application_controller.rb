class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate, except: [:token_login]
  before_action :set_locale

  helper_method :active_action?
  def active_action?(array)
    array.include?(params[:action]) ? " active" : ""
  end

  def token_login
    admin = Admin.where(authentication_token: params[:token]).first
    if admin.present?
      sign_in admin
      reset_authtication_token admin
      redirect_to root_path
    else
      if admin_signed_in?
        reset_authtication_token current_admin
        sign_out current_admin
      end
      authenticate
    end
  end

  private
    def authenticate
      redirect_to(new_admin_session_path) and return unless admin_signed_in?
    end

    def authenticate_with_token
      admin = Admin.where(authentication_token: params[:token]).first
      if admin.present?
        sign_in admin, store: false
      end
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

    def new_token
      SecureRandom.base64(40).tr('+/=lIO0', 'pqrsxyz')[0,40]
    end

    def reset_authtication_token admin
      admin.update authentication_token: new_token if admin.present?
    end

    def ensure_authentication_token admin
      reset_authtication_token admin if admin.present? && admin.authentication_token.length != 40
    end
end
