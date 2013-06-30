jobsonload = ->
  # notice and alert tooltip
  remove_notice_or_alert = ->
    $("#notice, #alert").fadeOut 200, ->
      $(this).remove()
  $("#notice, #alert").find(".close").click (e) ->
    e.preventDefault();
    remove_notice_or_alert();
  if $("#notice, #alert").length > 0
    setTimeout remove_notice_or_alert, 3000
  # the run button in job show page
  $("#run_job").click (e) ->
    e.preventDefault();
    run_job = $(this)
    if run_job.text() == run_job.data('run')
      run_job.text run_job.data('cancel')
      $("#output").empty().append("Please wait while connection is beeing established...\n")
      parameters = { parameters: {} };
      if $(".custom_param").length > 0
        $(".custom_param").each (a,b) ->
          parameters.parameters[$(this).data("param")] = $(this).val();
      if $("#exit_if_non_zero").prop("checked")
        parameters.exit_if_non_zero = 1
      window.source = new EventSource $(this).data('to') + "?" + $.param(parameters);
      window.source.addEventListener 'open', (e) ->
        $("#output").empty().append("> Connected.\n")
        $("#output").append(Array(50).join("-")+"\n")
      , false
      window.source.onmessage = (e) ->
        console.log e
        data = $.parseJSON e.data
        $("#output").append(data.output)
      window.source.addEventListener 'error', (e) ->
        if e.eventPhase == EventSource.CLOSED
          $("#output").append(Array(50).join("-")+"\n")
          $("#output").append("> Disconnected.\n")
        window.source.close();
        run_job.text run_job.data('run')
      , false
    else
      window.source.close();
      run_job.text run_job.data('run')
      $("#output").empty().append("Pending.\n")
  # render script text editor
  get_current_mode = ->
    mode = 'shell'
    if arguments[0]
      text = arguments[0]
    else
      text = $("#job_interpreter_id option:selected").text()
    bins = ["perl", "php", "python", "ruby"]
    mode = bin for bin in bins when text.indexOf(bin) isnt -1
    return mode
  set_runMode = ->
    CodeMirror.runMode($("#script").text(), get_current_mode($("#script").data("interpreter")), document.getElementById("script"));
  if $("#script").length > 0
    set_runMode();
  if $("#job_script").length > 0
    mode = get_current_mode()
    editor = CodeMirror.fromTextArea document.getElementById("job_script"), {
      theme: 'monokai',
      mode: mode,
      lineNumbers: true
    }
    $("#job_interpreter_id").change ->
      if editor
        editor.setOption("mode", get_current_mode())
  # behaviours of text inputs of custom parameters
  if $(".custom_param").length > 0
    $("#script").data("original", $("#script").text())
    $(".custom_param").bind 'keyup keydown', ->
      data = $("#script").data("original")
      $(".custom_param").each (a,b) ->
        value = $(this).val()
        if value != ''
          data = data.replace new RegExp('([^%]?)%{'+$(this).data('param')+'}', 'g'), (m, p1) ->
            return p1 + value
        $("#script").text(data)
        set_runMode();
  # select options for custom parameters
  if $(".fill_custom_param").length > 0
    $(".fill_custom_param").change ->
      $(this).closest(".pc").find(".custom_param").val($(this).val()).trigger('keydown')
      $(this).val('')
$(jobsonload)
$(window).bind 'page:change', jobsonload # because of turbolinks
