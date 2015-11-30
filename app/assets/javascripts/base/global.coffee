# Module definitions #
@cinnamonroll = {} if !@cinnamonroll

# Module constants #
@cinnamonroll.MAX_AJAX_ATTEMPTS = 3

# Constants
NAV_BAR_PEEK_REMS = '-3.5rem'
NAV_BAR_HIDE_REMS = '-4.5rem'
BEGIN_EASING_PERCENTAGE = 0.1
HOVER_SHOW_TIMEOUT = 250
HOVER_OUT_TIMEOUT = 500

# Instance variables #
eased_in = false
shown = false
show_timeout = null
$nav_bar = null
body_width = $('body').width()
body_height = $('body').height()

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

## Animating the top bar ##
@cinnamonroll.show_nav_bar = () ->
  $nav_bar.velocity("stop", true)
  $nav_bar.velocity {
    top: '0'
  }, {
    easing: 'easeInSine'
    duration: 100
  }

@cinnamonroll.peek_nav_bar = () ->
  $nav_bar.velocity("stop", true)
  $nav_bar.velocity {
    top: NAV_BAR_PEEK_REMS
  }, {
    easing: 'easeInSine'
    duration: 50
  }

@cinnamonroll.hide_nav_bar = () ->
  $nav_bar.velocity("stop", true)
  $nav_bar.velocity {
    top: NAV_BAR_HIDE_REMS
  }, {
    easing: 'easeInSine'
    duration: 250
  }
###########################

@cinnamonroll.on_page_load = (func) ->
  $(document).ready -> func()
  $(document).on 'page:load', -> func()

# static code #
$(window).resize ->
  body_width = $('body').width()
  body_height = $('body').height()

## register showing and hiding the nav bar when the mouse goes over it or leaves
@cinnamonroll.on_page_load ->
  $nav_bar = $('#nav-bar')
  $nav_bar.mouseenter((ev) ->
    clearTimeout show_timeout unless show_timeout == null
    show_timeout = setTimeout(() ->
      shown = true
      eased_in = true
      show_timeout = null
      $nav_bar.velocity("stop", true)
      cinnamonroll.show_nav_bar()
    , HOVER_SHOW_TIMEOUT)
  )
  $nav_bar.mouseleave((ev) ->
    clearTimeout show_timeout unless show_timeout == null
    show_timeout = setTimeout(() ->
      shown = false
      eased_in = false
      show_timeout = null
      $nav_bar.velocity("stop", true)
      cinnamonroll.hide_nav_bar()
    , HOVER_OUT_TIMEOUT)
  )
  $nav_bar.click((ev) ->
    shown = true
    eased_in = true
    if ev.which == 1
      cinnamonroll.show_nav_bar()
  )
  $nav_bar.find('a').click((ev) ->
    if !shown
      ev.preventDefault()
  )
  $(window).mouseleave((ev) ->
    if ev.clientX < 0 || ev.clientY < 0 || ev.clientY > body_height || ev.clientX >= body_width
      $nav_bar.trigger 'mouseleave'
  )

## Register the easing listener
@cinnamonroll.on_page_load ->
  $(window).mousemove((ev) ->
    # Breaks in firefox, wtf?
    if ev.buttons & 1 > 0
      return

    if !eased_in && ev.clientY / body_height < BEGIN_EASING_PERCENTAGE
      eased_in = true
      cinnamonroll.peek_nav_bar()
    else if eased_in && !shown && ev.clientY / body_height > BEGIN_EASING_PERCENTAGE
      eased_in = false
      cinnamonroll.hide_nav_bar()
  )
