reset_console = ->
  $("#javascriptConsole").html("")

$(document).ready(reset_console)
$(document).on('page:load', reset_console)

consolePrint = (message) ->
  $("#javascriptConsole").append(message + "<br>");
