adminsonload = ->
  $('.qrcode').each ->
    $(this).qrcode({ text: $(this).data('text'), width: 230, height: 230 });
$(adminsonload)
$(window).bind 'page:change', adminsonload # because of turbolinks
