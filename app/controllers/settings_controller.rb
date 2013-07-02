class SettingsController < ApplicationController
  before_action :authenticate

  def index
    @interpreters = Interpreter.all.to_a.concat([Interpreter.new(id: 0)])
    @constants = Constant.all.to_a.concat([Constant.new(id: 0)])
  end

  def update_interpreters
    errors = 0
    ids = params[:interpreters] || []
    paths = params[:interpreters_path] || []
    usf = params[:interpreters_usf] || []
    paths.each_index do |index|
      begin
        interpreter = Interpreter.find(ids[index])
        if paths[index].empty?
          errors = errors + 1 unless interpreter.destroy
        else
          errors = errors + 1 unless interpreter.update({ path: paths[index], upload_script_first: usf.include?(ids[index]) })
        end
      rescue ActiveRecord::RecordNotFound
        unless paths[index].empty?
          interpreter = Interpreter.new({ path: paths[index], upload_script_first: usf.include?(ids[index]) })
          errors = errors + 1 unless interpreter.save
        end
      end
    end
    respond_to do |format|
      if errors == 0
        format.html { redirect_to settings_path, notice: 'Interpreters were successfully updated.' }
      else
        format.html { redirect_to settings_path, alert: '#{errors} errors occurred when updating interpreters.' }
      end
    end
  end

  def update_constants
    errors = 0
    ids = params[:constants] || []
    names = params[:constants_name] || []
    names.each_index do |index|
      begin
        constant = Constant.find(ids[index])
        if names[index].empty?
          errors = errors + 1 unless constant.destroy
        else
          errors = errors + 1 unless constant.update({ name: names[index] })
        end
      rescue ActiveRecord::RecordNotFound
        unless names[index].empty?
          constant = Constant.new({ name: names[index], content: '' })
          errors = errors + 1 unless constant.save
        end
      end
    end
    respond_to do |format|
      if errors == 0
        format.html { redirect_to settings_path, notice: 'Constants were successfully updated.' }
      else
        format.html { redirect_to settings_path, alert: '#{errors} errors occurred when updating constants.' }
      end
    end
  end

  def get_constant
    constant = Constant.find(params[:id])
    render json: constant.to_json
  end

  def update_content_of_constant
    constant = Constant.find(params[:id])
    if constant.update({ content: params[:content] })
      render json: { content: constant.content.length }
    else
      render json: { content: -1 }, status: :unprocessable_entity
    end
  end

end
