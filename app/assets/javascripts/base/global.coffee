# Module definitions #
@cinnamonroll = {} if !@cinnamonroll

# Module constants #
@cinnamonroll.MAX_AJAX_ATTEMPTS = 3

# Constants

# Instance variables #

# instance/helper methods #

jQuery.fn.preventDoubleSubmission = ->
  $(this).on 'submit', (e) ->
    $form = $(this)

    if $form.data('submitted') == true
      # Previously submitted - don't submit again
      e.preventDefault();
    else
      # Mark it so that the next submit can be ignored
      $form.data 'submitted', true

  # Keep chainability
  this

# module functions #

@cinnamonroll.add_attr_to_form = (scope, param, value, form) ->
  $('<input type="hidden">').attr {
    id: "#{scope}_#{param}"
    name: "#{scope}[#{param}]"
    value: "#{value}"
  }
  .appendTo form

@cinnamonroll.is_populated_array = (subject) ->
  try
    if subject
      return true if subject[0]
    false
  catch
    false

@cinnamonroll.on_page_load = (func) ->
  $(document).ready -> func()
  $(document).on 'page:load', -> func()

@cinnamonroll.before_unload = (func) ->
  $(window).unload -> func()
  $(document).on 'page:before-unload', -> func()

@cinnamonroll.storage_available = (type) ->
  try
    storage = window[type]
    x = '__storage_test__'
    storage.setItem x, x
    storage.removeItem x
    true
  catch
    false

@cinnamonroll.storage_available_with_key_set_to = (type, key, value) ->
  if cinnamonroll.storage_available(type)
    storage = window[type]
    if storage.getItem(key) == value
      true
    else
      false
  else
    false

# static code #
