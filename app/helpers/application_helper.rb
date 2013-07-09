module ApplicationHelper
  def i18n_javascript_for_current_controller
    locale = I18n.backend.send(:translations)[I18n.locale]
    "window.I18n=" +
    locale[:javascript][params[:controller].to_sym].to_json.html_safe +
    ";"
  end

  def jquery_timeago_tranlations
    "jQuery.timeago.settings.strings=#{I18n.t("jquery_timeago")};"
  end
end
