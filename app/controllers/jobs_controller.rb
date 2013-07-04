class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :delete, :destroy, :timestats]

  helper_method :get_parameters_of
  def get_parameters_of(script)
    script.scan(/[^%]?%{(.+?)}/).flatten(1).uniq
  end

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.all
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @job_parameters = Constant.where("name = ?", "job_parameters").first || []
    @job_parameters = YAML::load @job_parameters.content unless @job_parameters.blank?
  end

  def timestats
    created_at = @job.time_stats.pluck(:created_at).last(12).map{|x| x.to_i }
    real = @job.time_stats.pluck(:real).last(12)

    created_at.push created_at[0] if created_at.length == 1
    real.push real[0] if real.length == 1

    render json: { created_at: created_at, real: real, mean_time: @job.mean_time }
  end

  # GET /jobs/new
  def new
    @job = Job.new
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs
  # POST /jobs.json
  def create
    create_job_with job_params
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.time_stats.clear
    @job.destroy
    session[:job_id] = nil
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # GET /jobs/1/run
  include ActionController::Live
  def run
    require 'streamer/sse'
    require 'net/ssh'
    require 'net/scp'
    require 'benchmark'

    response.headers['Content-Type'] = 'text/event-stream'
    sse = Streamer::SSE.new(response.stream)
    begin
      @job = Job.find(params[:id])
      begin
        raise "> Please select one server!" if @job.server.nil?

        ssh_params = [@job.server.host, @job.server.username, :password => @job.server.password, :timeout => 5]

        if @job.interpreter.try(:path)
          time_used = Benchmark.measure {
            Net::SSH.start *ssh_params do |ssh|
              if @job.interpreter.upload_script_first
                script = @job.script
                script.gsub!(/\r\n?/, "\n")
                ssh.scp.upload!(StringIO.new(script), "/tmp/easyjobs_script") do |ch, name, sent, total|
                  sse.write({ :output => "> Uploading #{name} ... #{(sent.to_f * 100 / total.to_f).to_i}% #{sent}/#{total} bytes sent\n" })
                end
                cmd = "#{@job.interpreter.path} /tmp/easyjobs_script"
                sse.write({ :output => "> Running #{cmd} ...\n" })
                ssh.exec!(cmd) do |channel, stream, data|
                  sse.write({ :output => data })
                end
              else
                ssh.open_channel do |channel|
                  channel.exec(@job.interpreter.path) do |ch, success|
                    channel.send_data @job.script
                    channel.eof!
                    channel.on_data do |ch,data|
                      sse.write({ :output => data })
                    end
                  end
                end
              end
            end
          }
          record_and_output_real_time time_used, @job, sse
        else

          # job without interpreter (default)
          script = @job.script
          script.gsub!(/\r\n?/, "\n")
          script.gsub!(/\\\n\s*/, "")

          # param substitute
          good_param = 0
          parameters = get_parameters_of(script)
          parameters.each do |p|
            good_param = good_param + 1 if params.has_key?(:parameters) and 
              params[:parameters].has_key?(p) and params[:parameters][p].length > 0
          end

          raise "> At least one parameter value is not provided!" if good_param != parameters.count

          script = script % params[:parameters].symbolize_keys if good_param > 0

          exit_if_non_zero = (params.has_key?(:exit_if_non_zero) && params[:exit_if_non_zero] == "1")

          # execute commands
          time_used = Benchmark.measure {
            Net::SSH.start *ssh_params do |ssh|
              script.lines.each do |line|
                line.strip!
                next if line.empty? or line[0] == "#"
                exit_code = 0
                ssh.exec!(line) do |channel, stream, data|
                  sse.write({ :output => data })
                  channel.on_request("exit-status") do |ch,data|
                    exit_code = data.read_long
                  end
                end
                raise "> Exit with status code #{exit_code}." if exit_if_non_zero and exit_code > 0
              end
            end
          }
          record_and_output_real_time time_used, @job, sse

        end
      rescue Timeout::Error
        sse.write({ :output => "> Timed out!\n" })
      rescue Net::SSH::AuthenticationFailed
        sse.write({ :output => "> Authentication failed!\n" })
      rescue Exception => e
        sse.write({ :output => "#{e.message}\n" })
      end
    rescue IOError
      # the client disconnects
    ensure
      sse.close
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])

      # remeber last entered job
      session[:job_id] = params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:name, :interpreter_id, :script, :server_id)
    end

    def record_and_output_real_time(time_used, job, sse)
      TimeStat.create([{ real: time_used.real, job_id: job.id, job_script_size: job.script.length }])
      mean_time = job.time_stats.average(:real)
      job.update({ mean_time: mean_time })
      sse.write({ :output => "> Time used: #{time_used.real} seconds.\n" })
      sse.write({ :output => "> Mean time: #{mean_time} seconds.\n" })
    end
end
