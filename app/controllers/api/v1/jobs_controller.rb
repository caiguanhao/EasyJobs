class Api::V1::JobsController < Api::V1Controller
  layout false

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
    require 'digest/md5'
    script_hash = Digest::MD5.hexdigest(job.script)
    render json: {
      job: job,
      interpreter: job.interpreter,
      server: server,
      hash: script_hash
    }
  end

  def run
    _p = params.has_key?(:parameters) ? { parameters: params[:parameters] } : {}
    p = params.permit(:token, :hash, :exit_if_non_zero).merge(_p).to_query
    p = "?" + p unless p.empty?
    @eventSource = run_job_path(params[:job_id]) + p
  end

end
