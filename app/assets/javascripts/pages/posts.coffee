# Module definitions #
@cinnamonroll = {} if !@cinnamonroll
@cinnamonroll.posts = {}

# Constants #

BEGIN_EASING_PERCENTAGE = 0.15
HOVER_SHOW_TIMEOUT = 250
HOVER_OUT_TIMEOUT = 500
SHOWN_KEY = 'shown_bar'
SHOWN_VALUE = 'true'

# instance variables #
side_bar_peek_point = '-4.5%'
side_bar_hide_point = '-9%'
eased_in = false
shown = false
show_timeout = null
body_width = $('body').width()
body_height = $('body').height()
$post_nav = null
pn_wid = null
triggered = false

# instance/helper methods #
reload_body_dim = () ->
  body_width = $('body').width()
  body_height = $('body').height()

initial_showing = (func) ->
  shown = true
  eased_in = true
  show_timeout = null
  $post_nav.velocity "stop", true
  cinnamonroll.posts.show_side_bar ->
    clearTimeout show_timeout unless show_timeout == null
    show_timeout = setTimeout(() ->
      shown = false
      eased_in = false
      show_timeout = null
      $post_nav.velocity "stop", true
      cinnamonroll.posts.hide_side_bar()
    , HOVER_OUT_TIMEOUT * 4)
    func() if func?

# module functions #
@cinnamonroll.posts.show_side_bar = (callback) ->
  $post_nav.velocity("stop", true)
  $post_nav.velocity {
    left: '0'
  }, {
    easing: 'easeInSine'
    duration: 100
    complete: callback if callback?
  }

@cinnamonroll.posts.peek_side_bar = () ->
  $post_nav.velocity("stop", true)
  $post_nav.velocity {
    left: side_bar_peek_point
  }, {
    easing: 'easeInSine'
    duration: 50
  }

@cinnamonroll.posts.hide_side_bar = () ->
  $post_nav.velocity("stop", true)
  $post_nav.velocity {
    left: side_bar_hide_point
  }, {
    easing: 'easeInSine'
    duration: 50
  }

# static code
$(window).resize ->
  reload_body_dim()

  pn_wid = $post_nav.outerWidth()
  $post_nav.css 'left', -(pn_wid + 1)
  side_bar_peek_point = -2 * pn_wid / 3
  side_bar_hide_point = -(pn_wid + 1)

@cinnamonroll.on_page_load ->
  reload_body_dim()

# Mouse movement over the post_nav
@cinnamonroll.on_page_load ->
  $post_nav = $('#post-nav')
  $post_nav.mouseenter((ev) ->
    clearTimeout show_timeout unless show_timeout == null
    show_timeout = setTimeout(() ->
      shown = true
      eased_in = true
      show_timeout = null
      triggered = false
      $post_nav.velocity("stop", true)
      cinnamonroll.posts.show_side_bar()
    , HOVER_SHOW_TIMEOUT)
  )
  $post_nav.mouseleave((ev) ->
    clearTimeout show_timeout unless show_timeout == null
    show_timeout = setTimeout(() ->
      # don't trigger if we're still over the element (perfect scroll)
      return if ev.clientX >= 0 && ev.clientX <= pn_wid
      shown = false
      eased_in = false
      show_timeout = null
      triggered = false
      $post_nav.velocity("stop", true)
      cinnamonroll.posts.hide_side_bar()
    , HOVER_OUT_TIMEOUT)
  )
  $post_nav.click((ev) ->
    shown = true
    eased_in = true
    if ev.which == 1
      cinnamonroll.posts.show_side_bar()
  )
  $post_nav.find('a').click((ev) ->
    if !shown
      ev.preventDefault()
  )
  $(window).mouseleave((ev) ->
    if ev.clientX < 0 || ev.clientY < 0 || ev.clientY > body_height
      $post_nav.trigger 'mouseleave'
  )
  # If a user holds and drags the scroll bar, the side nav isn't hidden. Hide it on mouse move
  $(window).mousemove((ev) ->
    if shown && !triggered && ev.clientX > pn_wid
      triggered = true
      $post_nav.trigger 'mouseleave'
  )

  pn_wid = $post_nav.outerWidth()
  $post_nav.css 'left', -(pn_wid + 1)
  side_bar_peek_point = -2 * pn_wid / 3
  side_bar_hide_point = -(pn_wid + 1)

  $post_nav.perfectScrollbar()

  if cinnamonroll.storage_available_with_key_set_to 'sessionStorage', SHOWN_KEY, SHOWN_VALUE
    shown = false
    eased_in = false
    show_timeout = null
    $post_nav.velocity("stop", true)
    cinnamonroll.posts.hide_side_bar()
  else
    initial_showing ->
      if cinnamonroll.storage_available 'sessionStorage'
        sessionStorage.setItem SHOWN_KEY, SHOWN_VALUE

# Easing event registration
@cinnamonroll.on_page_load ->
  $(window).mousemove((ev) ->
    if ev.buttons & 1 > 0
      return

    if !eased_in && ev.clientX / body_width < BEGIN_EASING_PERCENTAGE
      eased_in = true
      cinnamonroll.posts.peek_side_bar()
    else if eased_in && !shown && ev.clientX / body_width > BEGIN_EASING_PERCENTAGE
      eased_in = false
      cinnamonroll.posts.hide_side_bar()
  )

# Text areas expand as you type
@cinnamonroll.on_page_load ->
  autosize $('textarea') if autosize?
