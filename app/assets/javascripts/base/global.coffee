@cinnamonroll = {} if !@cinnamonroll

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
