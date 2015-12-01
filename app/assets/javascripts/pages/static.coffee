@cinnamonroll = {} if !@cinnamonroll

# Module constants #

# Constants
NUM_CATS = 4

# Instance variables #

# instance/helper methods #

# module functions #

# static code #
@cinnamonroll.on_page_load ->
  for num in [1..NUM_CATS]
    $("#cat-#{num}").hover(->
      $desc = $("##{$(this).attr 'id'}-desc")
      $desc.velocity 'stop', true
      $desc.velocity 'fadeIn', duration: 100, easing: 'ease'
    ,->
      $desc = $("##{$(this).attr 'id'}-desc")
      $desc.velocity 'stop', true
      $desc.velocity 'fadeOut', duration: 100, easing: 'ease'
    )
