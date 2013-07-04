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
        format.html { redirect_to @server, notice: 'Server was successfully created.' }
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
    job_params[:script] = <<END
# Put each of your separate command in each line:
#
# cd /srv && pwd
# 
# If your command is too long for one line, you can break the line
# with a back-slash (\\) at the end of the line:
# 
# jekyll build --source "/srv/source" --destination "/srv/site" \\
# --config "/srv/public.yml","/srv/source/_config.yml"
#
# Do not add comments (hashtag) after each command:
#
# du -sh . # Get the size of current directory

echo "You have successfully connected to the server."
END
    job_params[:server_id] = @server.id
    create_job_with job_params
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
      params.require(:server).permit(:name, :host, :username, :password, :constant_id)
    end
end
