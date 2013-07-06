class ServersController < ApplicationController
  before_action :set_server, only: [:show, :edit, :update, :delete, :destroy, :create_blank_job]

  # GET /servers
  # GET /servers.json
  def index
    @servers = Server.all
  end

  # GET /servers/1
  # GET /servers/1.json
  def show
  end

  # GET /servers/new
  def new
    @server = Server.new
  end

  # GET /servers/1/edit
  def edit
  end

  # POST /servers
  # POST /servers.json
  def create
    @server = Server.new(server_params)

    respond_to do |format|
      if @server.save
        format.html { redirect_to @server, notice: t('notice.server.created') }
        format.json { render action: 'show', status: :created, location: @server }
      else
        format.html { render action: 'new' }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_blank_job
    job_params = Hash.new
    job_params[:name] = "Blank job for #{@server.name}"
    job_params[:script] = t('default_script')
    job_params[:server_id] = @server.id
    create_job_with job_params
  end

  # PATCH/PUT /servers/1
  # PATCH/PUT /servers/1.json
  def update
    if params.has_key?(:save_and_go_back) and params.has_key?(:referrer)
      destination = params[:referrer]
    else
      destination = @server
    end

    if params[:server].has_key?(:need_password) && params[:server].has_key?(:password)
      case params[:server][:need_password]
        when "0"
          params[:server][:password] = ""
        when "1"
          if params[:server][:password].empty? then
            params[:server].delete :password
          end
      end
    end

    respond_to do |format|
      if @server.update(server_params)
        format.html { redirect_to destination, notice: t('notice.server.updated') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
  end

  # DELETE /servers/1
  # DELETE /servers/1.json
  def destroy
    @server.destroy
    session[:server_id] = nil
    respond_to do |format|
      format.html { redirect_to servers_url, notice: t('notice.server.deleted') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_server
      @server = Server.find(params[:id])
      if params.has_key?(:server) and params[:server].has_key?(:need_password)
        @server.need_password = params[:server][:need_password]
      else
        @server.need_password = !@server.password.empty?
      end

      # remeber last entered server
      session[:server_id] = params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def server_params
      params.require(:server).permit(:name, :host, :username, :password, :constant_id)
    end
end
