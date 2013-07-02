noticeonload = ->
  # notice and alert tooltip
  remove_notice_or_alert = ->
    $("#notice, #alert").fadeOut 200, ->
      $(this).remove()
  $("#notice, #alert").find(".close").click (e) ->
    e.preventDefault();
    remove_notice_or_alert();
  if $("#notice, #alert").length > 0
    setTimeout remove_notice_or_alert, 3000
$(noticeonload)
$(window).bind 'page:change', noticeonload
