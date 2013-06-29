jobsonload = ->
  $("#notice, #alert").find(".close").click (e) ->
    e.preventDefault();
    $("#notice, #alert").fadeOut 200, ->
      $(this).remove()
  $("#run_job").click (e) ->
    e.preventDefault();
    run_job = $(this)
    if run_job.text() == run_job.data('run')
      run_job.text run_job.data('cancel')
      $("#output").empty().append("Please wait while connection is beeing established...\n")
      window.source = new EventSource $(this).data('to');
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
$(jobsonload)
$(window).bind 'page:change', jobsonload # because of turbolinks
