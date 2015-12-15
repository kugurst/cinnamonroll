# Module definitions #
@cinnamonroll = {} if !@cinnamonroll
@cinnamonroll.comments = {}
cc = @cinnamonroll.comments

# Constants #

COMMENT_PARAM = 'comment'
ALL_COMMENT_PARAM = 'all'
POST_PARAM = 'post'
BODY_PARAM = 'body'
POST_FILE_PATH_PARAM = 'file_path'
POST_CATEGORY_PARAM = 'category'
COMMENT_ID_CLASS = 'comment'
COMMENT_ID_DATA = 'id'
DIV_ALL_COMMENTS_ID = 'all-comments'
COMMENT_ID = 'new-comment-box'
PARENT_COMMENT_ID = 'parent_comment_id'
SLIDE_DOWN_DURATION = 100
SLIDE_UP_DURATION = 50
CATEGORY_POS = 2
FILE_PATH_POS = 3

# instance variables #
$current_reply = null
write_a_comment = null

# module variables #

@cinnamonroll.comments.type_enum = Object.freeze {
  NEW: "new"
  REPLY: "reply"
}

# instance/helper methods #

add_additional_info = (form, $parent = null) ->
  cinnamonroll.add_attr_to_form COMMENT_PARAM, ALL_COMMENT_PARAM, true, form
  cinnamonroll.add_attr_to_form COMMENT_PARAM, PARENT_COMMENT_ID, $parent.data('id'), form if $parent?
  path_arr = location.pathname.split "/"
  cinnamonroll.add_attr_to_form POST_PARAM, POST_FILE_PATH_PARAM, path_arr[FILE_PATH_POS], form
  cinnamonroll.add_attr_to_form POST_PARAM, POST_CATEGORY_PARAM, path_arr[CATEGORY_POS], form


add_box = (parent, type, data) ->
  # Prepare animation by setting its display to none
  jdat = $(data).css 'display', 'none'

  # Ajax submit this form
  comment_form = jdat.find '.new-coment-form'
  comment_form.submit((ev) ->
    ev.preventDefault()
    return if !validate_form $(this)
    # add the parent comment if it's a reply
    add_additional_info this, if type == cc.type_enum.REPLY then parent else null
    # send the comment along
    cc.ajax_send_comment comment_form, parent
  )

  if type == cc.type_enum.NEW
    # save the new link comment to stick it back
    write_a_comment = $('#new-link')
    $(write_a_comment).slideUp duration: SLIDE_UP_DURATION, done: ->
      $(write_a_comment).remove()

  # Stick the box directly under the comment
  $(parent).append jdat[0]
  $(jdat).slideDown duration: SLIDE_DOWN_DURATION, done: ->
    $textarea = jdat.find '#new-comment-textarea'
    autosize $textarea
    $textarea.keydown((e) ->
      if e.keyCode == 13 && !e.shiftKey
        e.preventDefault()
        $textarea.submit()
    )
    $current_reply = $(parent).find '.new-comment-box'
    if type == cc.type_enum.NEW
      # Add an id to make it easy to identify this particular box
      $current_reply.attr 'id', COMMENT_ID
    if !$textarea.visible()
      $current_reply.velocity("scroll")
    $textarea.focus()

validate_form = ($form) ->
  form = $form[0]
  textarea = form["#{COMMENT_PARAM}[#{BODY_PARAM}]"]
  if !$.trim textarea.value
    notie.alert 3, "comments can't be empty", 2
    # $(textarea).notify "comments can't be empty", className: 'error', position: 'top right', autoHideDelay: 2000, arrowShow: false
    false
  else
    true

# module functions #
@cinnamonroll.comments.activate_links = ->
  $('.reply-link').click ->
    cinnamonroll.comments.get_comment_box this
    false
  $('#new-link').click ->
    cinnamonroll.comments.get_comment_box this, cc.type_enum.NEW
    false

@cinnamonroll.comments.ajax_send_comment = ($form, $parent) ->
  form = $form[0]
  # disable the submit button as well
  $form.find('.button').prop 'disabled', true
  cinnamonroll.sec.encrypt_and_ajax_submit_form_expect_json(form
    , (data, status, jq) ->
      $html = $(data.html).hide()
      $new_comment = $html.find "[data-id=\"#{data.id}\"]"
      $('#all-comments').fadeOut 175, ->
        $(this).replaceWith $html
        $('#all-comments').fadeIn 130, ->
          $('html,body').animate scrollTop: $new_comment.offset().top
        cinnamonroll.comments.activate_links()
    , (jq, status, e) ->
      json = JSON.parse jq.responseText
      if typeof json.error == 'string' || json.error instanceof String
        notie.alert 3, $.trim(json.error), 2
      else
        errors = ""
        for error, value of json.error
          errors += "#{error} #{value}<br>"
        notie.alert 3, $.trim(errors), 2
    , (dj, status, je) ->
      if status != 'success'
        # re-enable the form
        cinnamonroll.sec.reenable_form form
        # remove stale data
        $form.find("##{POST_PARAM}_#{POST_FILE_PATH_PARAM}").remove()
        $form.find("##{POST_PARAM}_#{POST_CATEGORY_PARAM}").remove()
        $form.find("##{COMMENT_PARAM}_#{PARENT_COMMENT_ID}").remove()
  )

@cinnamonroll.comments.get_comment_box = (reply_link, type = cc.type_enum.REPLY, attempt = 1) ->
  $parent = $(reply_link).parent()
  # regular reply links
  if type == cc.type_enum.REPLY
    while !$parent.hasClass(COMMENT_ID_CLASS)
      $parent = $parent.parent()
  # "Write a comment link" at the bottom of the page
  else if type == cc.type_enum.NEW
    while !$parent.is("##{DIV_ALL_COMMENTS_ID}")
      $parent = $parent.parent()

  jqxhr = $.ajax {
    type: 'GET'
    url: if type == cc.type_enum.REPLY then Routes.comments_box_reply_path() else Routes.comments_box_new_path()
  }
  .done (data, status, jq) ->
    if $current_reply != null
      $current_reply.slideUp duration: SLIDE_UP_DURATION, done: ->
        $current_reply.remove()
        # Stick back the "Write a comment" link if we removed it
        if $current_reply.attr('id') == COMMENT_ID
          $('#new-link-container').append write_a_comment[0]
          $(write_a_comment).slideDown duration: SLIDE_DOWN_DURATION
          # Stick back the new box comment
          $(write_a_comment).click ->
            cinnamonroll.comments.get_comment_box this, cc.type_enum.NEW
            false
        $current_reply = null
        add_box $parent, type, data
    else
      add_box $parent, type, data
  .fail (jq, status, e) ->
    if attempt < cinnamonroll.MAX_AJAX_ATTEMPTS
      cinnamonroll.comments.get_comment_box reply_link, type, attempt + 1

# Static code #
@cinnamonroll.on_page_load ->
  cinnamonroll.comments.activate_links()
