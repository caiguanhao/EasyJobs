class ServersController < ApplicationController
  before_action :authenticate
  before_action :set_server, only: [:show, :edit, :update, :delete, :destroy]

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
        format.html { redirect_to @server, notice: 'Server was successfully created.' }
        format.json { render action: 'show', status: :created, location: @server }
      else
        format.html { render action: 'new' }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /servers/1
  # PATCH/PUT /servers/1.json
  def update
    respond_to do |format|
      if @server.update(server_params)
        format.html { redirect_to @server, notice: 'Server was successfully updated.' }
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
      format.html { redirect_to servers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_server
      @server = Server.find(params[:id])

      # remeber last entered server
      session[:server_id] = params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def server_params
      params.require(:server).permit(:name, :host, :username, :password)
    end
end
