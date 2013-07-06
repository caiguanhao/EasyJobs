serversonload = ->
  if $('#server_need_password').length == 1
    $('#server_password').bind 'keyup keydown', ->
      $('#server_need_password').prop 'checked', $(this).val().length > 0
$(serversonload)
$(window).bind 'page:change', serversonload # because of turbolinks
