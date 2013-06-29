class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.all
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
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

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end

  # GET /jobs/1/run
  include ActionController::Live
  def run
    require 'streamer/sse'
    require 'net/ssh'
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Streamer::SSE.new(response.stream)
    begin
      @job = Job.find(params[:id])
      begin
        Net::SSH.start(@job.server.host, @job.server.username, :password => @job.server.password, :timeout => 5) do |ssh|
          if Job::Interpreters.include? @job.interpreter
            ssh.open_channel do |channel|
              channel.exec(@job.interpreter) do |ch, success|
                channel.send_data @job.script
                channel.eof!
                channel.on_data do |ch,data|
                  sse.write({ :output => data })
                end
              end
            end
          else
            script = @job.script
            script.gsub!(/\r\n?/, "\n").gsub!(/\\\n\s*/, "")
            script.lines.each do |line|
              line.strip!
              next if line.empty? or line[0] == "#"
              ssh.exec!(line) do |channel, stream, data|
                sse.write({ :output => data })
              end
            end
          end
        end
      rescue Timeout::Error
        sse.write({ :output => "Timed out!\n" })
      rescue Net::SSH::AuthenticationFailed
        sse.write({ :output => "Authentication failed!\n" })
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
      params.require(:job).permit(:name, :interpreter, :script, :server_id)
    end
end
