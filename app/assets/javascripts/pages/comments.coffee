@cinnamonroll = {} if !@cinnamonroll
@cinnamonroll.comments = {}
cc = @cinnamonroll.comments

@cinnamonroll.comments.type_enum = Object.freeze {
  NEW: "new"
  REPLY: "reply"
}

COMMENT_ID_CLASS = 'comment'
COMMENT_ID_DATA = 'id'
DIV_ALL_COMMENTS_CLASS = 'all-comments'
COMMENT_ID = 'new-comment-box'
SLIDE_DOWN_DURATION = 100
SLIDE_UP_DURATION = 50

current_reply = null
write_a_comment = null

add_box = (parent, type, data) ->
  # Animate the display of the item
  jdat = $(data).css 'display', 'none'

  if type == cc.type_enum.NEW
    # save the new link comment to stick it back
    write_a_comment = $('#new-link')
    $(write_a_comment).slideUp duration: SLIDE_UP_DURATION, done: ->
      $(write_a_comment).remove()

  # Stick the box directly under the comment
  $(parent).append jdat[0]
  $(jdat).slideDown duration: SLIDE_DOWN_DURATION, done: ->
    current_reply = $(parent).find '.new-comment-box'
    if type == cc.type_enum.NEW
      # Add an id to make it easy to identify this particular box
      $(current_reply).attr 'id', COMMENT_ID
    $('html,body').animate scrollTop: current_reply.offset().top

@cinnamonroll.comments.get_comment_box = (reply_link, type = cc.type_enum.REPLY, attempt = 1) ->
  parent = $(reply_link).parent()
  # regular reply links
  if type == cc.type_enum.REPLY
    while !$(parent).hasClass(COMMENT_ID_CLASS)
      parent = $(parent).parent()
  # "Write a comment link" at the bottom of the page
  else if type == cc.type_enum.NEW
    while !$(parent).hasClass(DIV_ALL_COMMENTS_CLASS)
      parent = $(parent).parent()

  jqxhr = $.ajax {
    type: 'GET'
    url: if type == cc.type_enum.REPLY then Routes.comments_box_reply_path() else Routes.comments_box_new_path()
  }
  .done (data, status, jq) ->
    if current_reply != null
      $(current_reply).slideUp duration: SLIDE_UP_DURATION, done: ->
        $(current_reply).remove()
        # Stick back the "Write a comment" link if we removed it
        if $(current_reply).attr('id') == COMMENT_ID
          $('#new-link-container').append write_a_comment[0]
          $(write_a_comment).slideDown duration: SLIDE_DOWN_DURATION
          # Stick back the new box comment
          $(write_a_comment).click ->
            cinnamonroll.comments.get_comment_box this, cc.type_enum.NEW
            false
        current_reply = null
        add_box parent, type, data
    else
      add_box parent, type, data
  .fail (jq, status, e) ->
    if attempt < cinnamonroll.MAX_AJAX_ATTEMPTS
      cinnamonroll.comments.get_comment_box reply_link, type, attempt + 1

@cinnamonroll.on_page_load ->
  $('.reply-link').click ->
    cinnamonroll.comments.get_comment_box this
    false

@cinnamonroll.on_page_load ->
  $('#new-link').click ->
    cinnamonroll.comments.get_comment_box this, cc.type_enum.NEW
    false
