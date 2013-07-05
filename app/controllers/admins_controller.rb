class AdminsController < ApplicationController
  before_action :set_admin, only: [:show, :edit, :update, :delete, :destroy]
  before_action :cant_change_admin_with_smaller_id, only: [:update, :destroy]

  # GET /admins
  # GET /admins.json
  def index
    @admins = Admin.all
  end

  # GET /admins/1
  # GET /admins/1.json
  def show
  end

  # GET /admins/new
  def new
    @admin = Admin.new
  end

  # GET /admins/1/edit
  def edit
  end

  # POST /admins
  # POST /admins.json
  def create
    @admin = Admin.new(admin_params)

    respond_to do |format|
      if @admin.save
        format.html { redirect_to @admin, notice: t('notice.admin.created') }
        format.json { render action: 'show', status: :created, location: @admin }
      else
        format.html { render action: 'new' }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admins/1
  # PATCH/PUT /admins/1.json
  def update
    # don't change password if it is empty
    params[:admin].delete :password if params[:admin][:password].empty?

    respond_to do |format|
      if @admin.update(admin_params)
        format.html { redirect_to @admin, notice: t('notice.admin.updated') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    # self-destruction
    if @admin.id == current_admin.id
      redirect_to :back, alert: t('alert.admin.commit_suicide') and return
    end

    # there will be no admins
    admin_count = Admin.count
    if admin_count <= 1
      redirect_to :back, alert: t('alert.admin.no_admins') and return
    end

    @admin.destroy
    session[:admin_id] = nil
    respond_to do |format|
      format.html { redirect_to admins_url, notice: t('notice.admin.deleted') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = Admin.find(params[:id])

      # remeber last entered job
      session[:admin_id] = params[:id]
    end

    def cant_change_admin_with_smaller_id
      if current_admin.id > @admin.id
        redirect_to :back, alert: t('alert.admin.cant_modify_admin') and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
      params.require(:admin).permit(:username, :email, :password)
    end
end
