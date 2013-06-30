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
      param = ''
      if $(".custom_param").length > 0
        parameters = { parameters: {} };
        $(".custom_param").each (a,b) ->
          parameters.parameters[$(this).data("param")] = $(this).val();
        param = "?" + $.param(parameters)
      window.source = new EventSource $(this).data('to') + param;
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
  if $("#job_script").length > 0
    editor = CodeMirror.fromTextArea document.getElementById("job_script"), {
      theme: 'monokai',
      mode: 'shell',
      lineNumbers: true
    }
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
  # select options for custom parameters
  if $(".fill_custom_param").length > 0
    $(".fill_custom_param").change ->
      $(this).closest(".pc").find(".custom_param").val($(this).val()).trigger('keydown')
      $(this).val('')
$(jobsonload)
$(window).bind 'page:change', jobsonload # because of turbolinks
