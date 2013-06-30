settingsonload = ->
  $('.edit-constant-content').click (e) ->
    console.log(e);
    e.preventDefault();
    textarea = $('<textarea />', {cols:40, id: "constant_content", rows: 10})
    $('<div />').append(textarea).appendTo('body').modal().on $.modal.BEFORE_CLOSE, (event, modal) ->
      $("div.modal").remove();
    editor = CodeMirror.fromTextArea document.getElementById("constant_content"), {
      theme: 'monokai',
      mode: 'plain',
      lineNumbers: true
    }
    $.modal.resize()
$(settingsonload)
$(window).bind 'page:change', settingsonload # because of turbolinks
