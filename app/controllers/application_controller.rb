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

    def create_job_with(job_params)
      @job = Job.new(job_params)

      respond_to do |format|
        if @job.save
          format.html { redirect_to @job, notice: 'Job was successfully created.' }
          format.json { render action: 'show', status: :created, location: @job }
        else
          format.html { render action: 'new' }
          format.json { render json: @job.errors, status: :unprocessable_entity }
        end
      end
    end
end
