function reset_console() {
    $("#javascriptConsole").html("");
}

$(document).ready(reset_console);
$(document).on('page:load', reset_console);

function consolePrint(message) {
    $("#javascriptConsole").append(message + "<br>");
}
