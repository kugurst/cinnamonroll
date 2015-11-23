@cinnamonroll = {} if !@cinnamonroll
@cinnamonroll.comments = {}
cc = @cinnamonroll.comments

@cinnamonroll.comments.type_enum = Object.freeze {
  NEW: "new"
  REPLY: "reply"
}

COMMENT_ID_CLASS = 'comment'
COMMENT_ID_DATA = 'id'

current_reply = null

@cinnamonroll.comments.get_comment_box = (reply_link, type = cc.type_enum.REPLY, attempt = 0) ->
  parent = $(reply_link).parent()
  while !$(parent).hasClass(COMMENT_ID_CLASS)
    parent = $(parent).parent()

  jqxhr = $.ajax {
    type: 'GET'
    url: Routes.comments_partials_reply_box_path()
  }
  .done (data, status, jq) ->
    if current_reply != null
      $(current_reply).remove()
      current_reply = null

    $(parent).append(data)
    current_reply = $(parent).find('.new-comment-box')
  .fail (jq, status, e) ->
    if attempt < cinnamonroll.MAX_AJAX_ATTEMPTS
      cinnamonroll.comments.get_comment_box reply_link, attempt + 1

@cinnamonroll.on_page_load ->
  $('.reply-link').click ->
    cinnamonroll.comments.get_comment_box this
    false

@cinnamonroll.on_page_load ->
  $('#new-link').click ->
    cinnamonroll.comments.get_comment_box this, cc.NEW
    false
