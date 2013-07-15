class Api::V1::JobsController < Api::V1Controller

  def index
    render json: Job.joins('LEFT JOIN servers ON servers.id = jobs.server_id')
      .select('jobs.id, jobs.name, servers.name as server_name')
  end

  def show
    job = Job.where('jobs.id = ?', params[:id]).first
    server = job.server
    if server
      server = job.server.attributes
      server.delete("password")
    end
    render json: {
      job: job,
      interpreter: job.interpreter,
      server: server
    }
  end

  def run
    render json: {}
  end

end
