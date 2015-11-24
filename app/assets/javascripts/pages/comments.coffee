@cinnamonroll = {} if !@cinnamonroll
@cinnamonroll.comments = {}
cc = @cinnamonroll.comments

COMMENT_PARAM = 'comment'
BODY_PARAM = 'body'
COMMENT_ID_CLASS = 'comment'
COMMENT_ID_DATA = 'id'
DIV_ALL_COMMENTS_CLASS = 'all-comments'
COMMENT_ID = 'new-comment-box'
PARENT_COMMENT_ID = 'parent_comment_id'
SLIDE_DOWN_DURATION = 100
SLIDE_UP_DURATION = 50

current_reply = null
write_a_comment = null

@cinnamonroll.comments.type_enum = Object.freeze {
  NEW: "new"
  REPLY: "reply"
}

add_parent_comment = (form, parent) ->
  $('<input type="hidden">').attr {
    id: "#{COMMENT_PARAM}_#{PARENT_COMMENT_ID}"
    name: "#{COMMENT_PARAM}[#{PARENT_COMMENT_ID}]"
    value: "#{parent.data 'id'}"
  }
  .appendTo form

add_box = (parent, type, data) ->
  # Prepare animation by setting its display to none
  jdat = $(data).css 'display', 'none'

  # Ajax submit this form
  comment_form = jdat.find '.new-coment-form'
  comment_form.submit (ev) ->
    ev.preventDefault()
    return if !validate_form($(this))
    # add the parent comment if it's a reply
    if type == cc.type_enum.REPLY
      add_parent_comment this, parent
    # send the comment along
    cc.ajax_send_comment comment_form, parent

  if type == cc.type_enum.NEW
    # save the new link comment to stick it back
    write_a_comment = $('#new-link')
    $(write_a_comment).slideUp duration: SLIDE_UP_DURATION, done: ->
      $(write_a_comment).remove()

  # Stick the box directly under the comment
  $(parent).append jdat[0]
  $(jdat).slideDown duration: SLIDE_DOWN_DURATION, done: ->
    autosize jdat.find '#new-comment-textarea'
    current_reply = $(parent).find '.new-comment-box'
    if type == cc.type_enum.NEW
      # Add an id to make it easy to identify this particular box
      $(current_reply).attr 'id', COMMENT_ID
    $('html,body').animate scrollTop: current_reply.offset().top

bad_timeout = null
validate_form = ($form) ->
  form = $form[0]
  textarea = form["#{COMMENT_PARAM}[#{BODY_PARAM}]"]
  if !$.trim textarea.value
    notie.alert 3, "comments can't be empty", 2
    false
  else
    true

@cinnamonroll.comments.ajax_send_comment = ($form, parent) ->
  form = $form[0]
  # disable the submit button as well
  $form.find('.button').prop 'disabled', true
  cinnamonroll.sec.encrypt_and_ajax_submit_form_expect_json(form
    , (data, status, jq) ->
      console.log data
    , (jq, status, e) ->
      return
    , (dj, status, je) ->
      cinnamonroll.sec.reenable_form form
      $form.find("##{COMMENT_PARAM}_#{PARENT_COMMENT_ID}").remove()
  )

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
