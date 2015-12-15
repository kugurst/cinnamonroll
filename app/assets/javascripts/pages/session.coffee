# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# Module definitions #
@cinnamonroll = {} if !@cinnamonroll
@cinnamonroll.session = {}
cs = @cinnamonroll.session

# Constants #
SUBSTITUTE_ERROR_NAMES = {
  "name": "username"
}

# instance variables #
$login_create_form = null

# module variables #

# instance/helper methods #
validate_form = ($form) ->
  $inputs = $form.find '.sec_field'
  empty_value_found = false
  $inputs.each((i) ->
    if !$.trim $(this).val()
      $(this).notify "can't be empty", className: 'error', position: 'right', autoHideDelay: 2000, arrowShow: false
      empty_value_found = true
  )
  !empty_value_found

substitute_error_name = (error_name) ->
  if error_name of SUBSTITUTE_ERROR_NAMES
    SUBSTITUTE_ERROR_NAMES[error_name]
  else
    error_name

# module functions #
@cinnamonroll.session.ajax_send_form = ($form) ->
  $form.find('.button').prop 'disabled', true
  cinnamonroll.sec.encrypt_and_ajax_submit_form_expect_json $form[0]
    , (data, status, jq) ->
      window.location.href = data.url
      cinnamonroll.store.set 'notice', data.notice if 'notice' of data
    , (jq, status, e) ->
      json = JSON.parse jq.responseText
      if typeof json.error == 'string' || json.error instanceof String
        notie.alert 3, $.trim json.error, 2
        # $('.button').notify json.error, className: 'error', position: 'bottom', autoHideDelay: 2000, arrowShow: false
      else
        errors = ""
        for error, value of json.error
          $input = $form.find("input[name*='#{error}']")
          errors += "#{substitute_error_name error} #{value}<br>"
          # console.log $input[0]
          # $input.notify value, className: 'error', position: 'right', autoHideDelay: 2000, arrowShow: false if $input.length > 0
        notie.alert 3, $.trim errors, 2
    , (dj, status, je) ->
      if status != 'success'
        # re-enable the form
        cinnamonroll.sec.reenable_form $form[0]


# Static code #
@cinnamonroll.on_page_load ->
  $login_create_form = $('form')
  $login_create_form.submit((ev) ->
    ev.preventDefault()
    return if !validate_form $(this)
    cs.ajax_send_form $(this)
  )
