@cinnamonroll = {} if !@cinnamonroll

@cinnamonroll.MAX_AJAX_ATTEMPTS = 3

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
