# Module definitions #
@cinnamonroll = {} if !@cinnamonroll
@cinnamonroll.posts = {}

# Constants #

BEGIN_EASING_PERCENTAGE = 0.2
HOVER_SHOW_TIMEOUT = 500
SIDE_BAR_PEEK_PERCENTAGE = '-7%'
SIDE_BAR_HIDE_PERCENTAGE = '-10%'

# instance variables #

eased_in = false
shown = false
show_timeout = null
body_width = $(window).width()
$post_nav = null

# instance/helper methods #

# module functions #

@cinnamonroll.posts.show_side_bar = () ->
  $('.velocity-animating').velocity("stop", true)
  $('#post-nav').velocity {
    left: '0'
  }, {
    easing: 'easeInSine'
    duration: 100
  }

@cinnamonroll.posts.peek_side_bar = () ->
  $('.velocity-animating').velocity("stop", true)
  $('#post-nav').velocity {
    left: SIDE_BAR_PEEK_PERCENTAGE
  }, {
    easing: 'easeInSine'
    duration: 50
  }

@cinnamonroll.posts.hide_side_bar = () ->
  $('.velocity-animating').velocity("stop", true)
  $('#post-nav').velocity {
    left: SIDE_BAR_HIDE_PERCENTAGE
  }, {
    easing: 'easeInSine'
    duration: 50
  }

# static code
$(window).resize ->
  body_width = $('body').width()

@cinnamonroll.on_page_load ->
  $post_nav = $('#post-nav')
  $post_nav.mouseenter((ev) ->
    clearTimeout show_timeout unless show_timeout == null
    show_timeout = setTimeout(() ->
      unless !shown
        return
      shown = true
      eased_in = true
      cinnamonroll.posts.show_side_bar()
      show_timeout = null
    , HOVER_SHOW_TIMEOUT)
  )
  $post_nav.mouseleave((ev) ->
    clearTimeout show_timeout unless show_timeout == null
    show_timeout = setTimeout(() ->
      unless shown
        return
      shown = false
      eased_in = false
      cinnamonroll.posts.hide_side_bar()
      show_timeout = null
    , HOVER_SHOW_TIMEOUT)
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

@cinnamonroll.on_page_load ->
  $('body').mousemove((ev) ->
    if !eased_in && ev.pageX / body_width < BEGIN_EASING_PERCENTAGE
      eased_in = true
      cinnamonroll.posts.peek_side_bar()
    else if eased_in && !shown && ev.pageX / body_width > BEGIN_EASING_PERCENTAGE
      eased_in = false
      cinnamonroll.posts.hide_side_bar()
  )

@cinnamonroll.on_page_load ->
  autosize $('textarea')
