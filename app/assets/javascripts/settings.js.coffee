settingsonload = ->
  $('.edit-constant-content').click (e) ->
    link = $(this)
    action = $(this).data('action')
    e.preventDefault();
    notice = $('<div />',{style:"margin: 3px 0"}).text(I18n.close_to_save)
    textarea = $('<textarea />', {cols:40, id: "constant_content", rows: 10}).val("Loading...")
    editor = null
    $('<div />').append(notice).append(textarea).appendTo('body').modal().on $.modal.BEFORE_CLOSE, (event, modal) ->
      $.ajax({
          url: action ,
          type: 'PUT',
          data: { content: editor.getValue() }
          success: (data) ->
            link.closest('tr').find('td.size').text(data.content) # update new constant size
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
