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
CONFIRM_PREFIX = "confirm_"
RESEND_TEXT_FIELD_ID = "session_email_or_username"
MINIMUM_PASSWORD_LENGTH = 8

# instance variables #
$login_create_form = null

# module variables #

# instance/helper methods #
get_input_label_name = ($form, $input) ->
  $label = $form.find "label[for='#{$input.attr 'id'}']"
  $label.html()

validate_password = (password_str) ->
  errors = ""
  if password_str.length < MINIMUM_PASSWORD_LENGTH
    errors += "password too short<br>"
  $username = $("input[name*='name']").not("[name^='#{CONFIRM_PREFIX}']")
  if password_str == $username.val()
    errors += "password cannot be the same as your username nor email"
  $email = $("input[name*='email']").not("[name^='#{CONFIRM_PREFIX}']")
  if password_str == $email.val()
    errors += "password cannot be the same as your username nor email"
  errors

validate_form = ($form) ->
  $inputs = $form.find '.sec_field'
  bad_value_found = false
  errors = ""
  $inputs.each((i) ->
    $this = $(this)
    if !$.trim $this.val()
      errors += "#{get_input_label_name $form, $this} can't be empty<br>"
      bad_value_found = true
    # If this input's id begins with confirm, seek out what it's confirming and ensure they match
    else if this.name.startsWith CONFIRM_PREFIX
      # Seek out the field it's confirming
      $to_confirm = $form.find("input[name*='#{this.name.replace CONFIRM_PREFIX, ""}']").not("[name^='#{CONFIRM_PREFIX}']")
      # validate the password
      if $to_confirm.attr('id').indexOf('password') >= 0
        password_errors = validate_password $to_confirm.val()
        if !!password_errors
          errors += password_errors
          bad_value_found = true
      if $to_confirm.val() != $this.val()
        errors += "#{get_input_label_name $form, $to_confirm} must match<br>"
        bad_value_found = true
  )
  notie.alert 3, $.trim(errors), 2 if bad_value_found
  !bad_value_found

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
        notie.alert 3, $.trim(json.error), 2
        # $('.button').notify json.error, className: 'error', position: 'bottom', autoHideDelay: 2000, arrowShow: false
      else
        errors = ""
        for error, value of json.error
          # $input = $form.find("input[name*='#{error}']")
          errors += "#{substitute_error_name error} #{value}<br>"
          # console.log $input[0]
          # $input.notify value, className: 'error', position: 'right', autoHideDelay: 2000, arrowShow: false if $input.length > 0
        notie.alert 3, $.trim(errors), 2
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

# Set the href of the resend confirmation link
@cinnamonroll.on_page_load ->
  $resend = $('#resend-confirmation')
  $email_field = $("##{RESEND_TEXT_FIELD_ID}")
  if $resend.length > 0 && $email_field.length > 0
    $email_field.change((ev) ->
      email_str = $email_field.val()
      if !!email_str
        $resend[0].href = Routes.send_confirm_user_path $email_field.val()
      else
        $resend[0].href = ''
    )
