class Api::V1Controller < ApplicationController
  skip_before_action :authenticate
  before_action :authenticate_with_token

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
      }
    }
  end

end
