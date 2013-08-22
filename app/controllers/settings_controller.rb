class SettingsController < ApplicationController

  def index
    @types = Type.all.to_a.concat([Type.new(id: 0)])
    @interpreters = Interpreter.all.to_a.concat([Interpreter.new(id: 0)])
    @constants = Constant.all.to_a.concat([Constant.new(id: 0)])
  end

  def update_types
    errors = 0
    ids = params[:types] || []
    names = params[:types_name] || []
    names.each_index do |index|
      begin
        type = Type.find(ids[index])
        if names[index].empty?
          errors = errors + 1 unless type.destroy
        else
          errors = errors + 1 unless type.update({ name: names[index] })
        end
      rescue ActiveRecord::RecordNotFound
        unless names[index].empty?
          type = Type.new({ name: names[index] })
          errors = errors + 1 unless type.save
        end
      end
    end
    respond_to do |format|
      if errors == 0
        format.html { redirect_to settings_path, notice: t('notice.types.updated') }
      else
        format.html { redirect_to settings_path, alert: t('alert.types.error_updating', count: errors) }
      end
    end
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
        format.html { redirect_to settings_path, notice: t('notice.interpreters.updated') }
      else
        format.html { redirect_to settings_path, alert: t('alert.interpreters.error_updating', count: errors) }
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
        format.html { redirect_to settings_path, notice: t('notice.constants.updated') }
      else
        format.html { redirect_to settings_path, alert: t('alert.constants.error_updating', count: errors) }
      end
    end
  end

  def get_constant
    constant = Constant.find(params[:id])
    constant.content = private_key_mask if is_a_private_key?(constant.content)
    render json: constant.to_json
  end

  def update_content_of_constant
    constant = Constant.find(params[:id])
    content = params[:content]
    if content == private_key_mask and is_a_private_key?(constant.content) then
      render json: { content: constant.content.length }
    else
      if constant.update({ content: content })
        render json: { content: content.length }
      else
        render json: { content: -1 }, status: :unprocessable_entity
      end
    end
  end

  private
    def is_a_private_key?(content)
      content =~ /-----BEGIN RSA PRIVATE KEY-----/ or
      content =~ /-----BEGIN DSA PRIVATE KEY-----/
    end

    def private_key_mask
      "<<< PRIVATE KEY - NOT SHOWN >>>"
    end
end
