class SettingsController < ApplicationController

  def index
    @interpreters = Interpreter.all.to_a.concat([Interpreter.new(id: 0)])
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

  private
    def server_params
      params.permit(:interpreters[], :interpreters_path[], :interpreters_usf[])
    end
end
