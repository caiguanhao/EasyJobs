class Api::V1Controller < ApplicationController
  skip_before_action :authenticate
  before_action :authenticate_with_token
  skip_before_filter :verify_authenticity_token, only: [:tokens]

  include AdminsHelper

  def help
    render json: {
      jobs: {
        index: {
          verb: :get,
          url: better_path(api_v1_jobs_url)
        },
        show: {
          verb: :get,
          url: better_path(api_v1_job_url(":id"))
        },
        run: {
          verb: :get,
          url: better_path(api_v1_job_run_url(":id"))
        },
      },
      job_parameters: {
        index: {
          verb: :get,
          url: better_path(api_v1_parameters_url)
        }
      },
      tokens: {
        revoke: {
          verb: :delete,
          url: better_path(api_v1_revoke_token_url)
        }
      }
    }
  end

  # revoke tokens
  def tokens
    current_admin.reset_authentication_token!
    render nothing: true, status: 200
  end

  def parameters
    job_parameters = Constant.where("name = ?", "job_parameters").first || []
    job_parameters = YAML::load job_parameters.content unless job_parameters.blank?
    render json: job_parameters
  end

end
