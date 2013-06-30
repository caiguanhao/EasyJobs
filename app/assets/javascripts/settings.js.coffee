settingsonload = ->
  $('.edit-constant-content').click (e) ->
    action = $(this).data('action')
    e.preventDefault();
    textarea = $('<textarea />', {cols:40, id: "constant_content", rows: 10}).val("Loading...")
    editor = null
    $('<div />').append(textarea).appendTo('body').modal().on $.modal.BEFORE_CLOSE, (event, modal) ->
      $.ajax({
          url: action ,
          type: 'PUT',
          data: { content: editor.getValue() }
          success: (data) ->
            console.log data
      });
      $("div.modal").remove();
    editor = CodeMirror.fromTextArea document.getElementById("constant_content"), {
      theme: 'monokai',
      mode: 'yaml',
      lineNumbers: true
    }
    $.modal.resize()
    $.getJSON action, (data) ->
      editor.setValue(data.content)
$(settingsonload)
$(window).bind 'page:change', settingsonload # because of turbolinks
