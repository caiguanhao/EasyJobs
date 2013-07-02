jobsonload = ->
  # the run button in job show page
  output_scroll_to_bottom = ->
    $('#output').clearQueue().animate({scrollTop: $('#output')[0].scrollHeight});
  $("#run_job").click (e) ->
    e.preventDefault();
    run_job = $(this)
    if run_job.text() == run_job.data('run')
      dur = $("#mean_time").data("mean-time")
      init = "99%"
      if dur == 0
        dur = 2000
        init = "90%"
      else
        dur = dur * 1000
      $("#progress span").stop().clearQueue().animate { width: "0%" }, ->
        $("#progress span").animate({ width: init }, dur);
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
        output_scroll_to_bottom()
      window.source.addEventListener 'error', (e) ->
        if e.eventPhase == EventSource.CLOSED
          $("#output").append(Array(50).join("-")+"\n")
          $("#output").append("> Disconnected.\n")
          update_chart();
          $("#progress span").stop().clearQueue().animate { width: "100%" }, ->
            $("#progress span").delay(3000).animate { width: "0%" }
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
  # chart
  pad = (str, max) ->
    str = str.toString()
    return if str.length < max then pad("0" + str, max) else str;
  update_chart = ->
    $.getJSON $("#chart").data("json"), (data) ->
      chart = $('#chart').highcharts()
      if chart
        chart.destroy();
      if data.hasOwnProperty("real") && data.real.length > 0
        if data.mean_time != null
          $("#mean_time").data("mean-time", data.mean_time).text(data.mean_time + " s")
        $('#chart').removeClass("never").highcharts({
          chart: { type: 'areaspline' },
          title: { text: null },
          xAxis: { minTickInterval: 1, categories: data.created_at, labels: { formatter: ->
            date = new Date(this.value * 1000)
            return pad(date.getMonth()+1,2) + "-" + pad(date.getDate(),2) + "<br />" + pad(date.getHours(),2) + ":" + pad(date.getMinutes(),2)
          } },
          yAxis: [ { title: { text: null }, showFirstLabel: false },
                   { title: { text: null }, showFirstLabel: false, linkedTo: 0, opposite: true }],
          tooltip: { shared: true, formatter: ->
            date = new Date(this.x * 1000)
            return date.getFullYear() + "-" + pad(date.getMonth()+1,2) + "-" + pad(date.getDate(),2) + " " + 
            pad(date.getHours(),2) + ":" + pad(date.getMinutes(),2) + ":" + pad(date.getSeconds(),2)+
            '<br /><b>Time used: '+this.y+' seconds</b>';
          },
          credits: { enabled: false },
          plotOptions: { areaspline: { fillOpacity: 0.5, pointPlacement: 'on' } },
          series: [{
            name: 'Time used',
            data: data.real
          }]
        });
  if $('#chart').length > 0
    update_chart();
$(jobsonload)
$(window).bind 'page:change', jobsonload # because of turbolinks
