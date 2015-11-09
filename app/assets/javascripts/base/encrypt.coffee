# Module definition #
@cinnamonroll = {} if !@cinnamonroll
@cinnamonroll.sec = {}
cs = @cinnamonroll.sec
rsa = forge.pki.rsa


# Constant declaration #
AES_PARAMS = "aes"
RSA_PARAM = "rsa"
IV_PARAM = "iv"
KEY_PARAM = "key"
AES_IV_PARAM = AES_PARAMS + "_" + IV_PARAM
AES_KEY_PARAM = AES_PARAMS + "_" + KEY_PARAM
RSA_KEY_PARAM = RSA_PARAM + "_" + KEY_PARAM
RSA_MODULUS_PARAM = "modulus"
RSA_EXPONENT_PARAM = "exponent"
ENC_PARAM = "enc"
ACTIVE_PARAM = "active"
ENC_ACTIVE_PARAM = ENC_PARAM + "_" + ACTIVE_PARAM
REJECTED_FORM_KEYS = ["commit", "authenticity_token", "utf8", AES_IV_PARAM]
APPROVED_FORM_ELEMENT_TYPES = ["text", "password", "email"]
MAX_ATTEMPTS = 3
NO_KEY_STATUS = 424

# Environment Setup #


# Utility functions #
storageAvailable = (type) ->
  try
    storage = window[type]
    x = '__storage_test__'
    storage.setItem x, x
    storage.removeItem x
    true
  catch
    false

isLocalStorageAvailable = ->
  storageAvailable 'localStorage'

## Keys that are not to be encrypted, either because they're rails values or something else
isRejectedInputElement = (name) ->
  REJECTED_FORM_KEYS.indexOf(name.toLowerCase()) >= 0

## Elements that are allowed to be encrypted
isApprovedInputElementType = (type) ->
  APPROVED_FORM_ELEMENT_TYPES.indexOf(type.toLowerCase()) >= 0

onPageLoad = (func) ->
  $(document).ready -> func()
  $(document).on 'page:load', -> func()

replacePageContent = (content) ->
  document.open()
  document.write content
  document.close()

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


# Module function definitions #
@cinnamonroll.sec.send_pk = (success_func, fail_func, attempt = 0) ->
  cs.rsa_pair = rsa.generateKeyPair bits: 2048, workers: -1 if !cs.rsa_pair
  n64 = forge.util.encode64 cs.rsa_pair.publicKey.n.toString()
  e64 = forge.util.encode64 cs.rsa_pair.publicKey.e.toString()

  jqxhr = $.ajax {
    type: "POST"
    url: Routes.security_post_rsa_key_path()
    data: { "#{RSA_PARAM}": { "#{RSA_MODULUS_PARAM}": n64, "#{RSA_EXPONENT_PARAM}": e64 } }
  }
  .done (data, status, jq) ->
    success_func data, status, jq
  .fail (jq, status, e) ->
    if attempt < MAX_ATTEMPTS
      cs.send_pk success_func, fail_func, attempt + 1
    else
      fail_func jq, status, e

@cinnamonroll.sec.recv_aes_key = (data, status, jq, attempt = 0, func) ->
  jqxhr = $.ajax {
    type: "GET"
    url: Routes.security_get_aes_key_path()
  }
  .done (dat, stat, j) ->
    js = JSON.parse dat
    raes = forge.util.decode64 js[AES_KEY_PARAM]
    aes_key_64 = cs.rsa_pair.privateKey.decrypt raes
    cs.aes_key = forge.util.decode64 aes_key_64
    if isLocalStorageAvailable
      localStorage.setItem AES_KEY_PARAM, aes_key_64
    func() if func
  .fail (j, stat, e) ->
    if attempt < MAX_ATTEMPTS
      cs.recv_aes_key data, status, jq, attempt + 1
    else
      cs.set_no_enc

@cinnamonroll.sec.set_no_enc = ->
  cs.NO_ENCRYPTION = true
  # Record for future prosperity
  if storageAvailable 'sessionStorage'
    sessionStorage.setItem ENC_ACTIVE_PARAM, JSON.stringify cs.NO_ENCRYPTION

@cinnamonroll.sec.req_aes_key = (func) ->
  cs.send_pk(((data, status, jq) -> cs.recv_aes_key data, status, jq, 0, func), cs.set_no_enc) unless cs.rsa_pair

# Returns a byte array containing the decrypted base64 string
@cinnamonroll.sec.decrypt = (string, key, iv) ->
  decipher = forge.cipher.createDecipher 'AES-CBC', key
  encrypted = forge.util.decode64 string
  decipher.start {iv: iv}
  decipher.update forge.util.createBuffer(encrypted, 'binary')
  decipher.finish()
  decipher.output.toString 'utf8'

# Returns a base64 string representing the given string
@cinnamonroll.sec.encrypt_string = (string, key, iv) ->
  cipher = forge.cipher.createCipher 'AES-CBC', key
  cipher.start {iv: iv}
  cipher.update forge.util.createBuffer(string, 'utf8')
  cipher.finish()
  forge.util.encode64 cipher.output.getBytes()

@cinnamonroll.sec.encrypt_form = (attachedForm) ->
  if cs.NO_ENCRYPTION
    # Add the no_enc field to the form
    $('<input type="hidden">').attr {
      id: "#{ENC_PARAM}_#{ACTIVE_PARAM}"
      name: "#{ENC_PARAM}[#{ACTIVE_PARAM}]"
      value: "false"
    }
    .appendTo attachedForm
    return true

  stack = new Array()
  iv = forge.random.getBytesSync 32

  stack.push(attachedForm)
  while stack.length > 0
    next = stack.pop()
    if next not instanceof HTMLInputElement
      stack.push elem for elem in next
    else
      # Rails add some default form fields
      if !isRejectedInputElement next.name
        # For supported a wide variety of types
        if isApprovedInputElementType next.type
          # console.log "next name: #{next.name}, next id: #{next.id}"
          # console.log "attached form: #{attachedForm}, attached form id: #{attachedForm.id}, type: #{attachedForm.type}"
          $('<input type="hidden">').attr {
            id: "#{ENC_PARAM}_#{next.id}"
            name: "#{ENC_PARAM}[#{next.name}]"
            value: "#{cs.encrypt_string next.value, cs.aes_key, iv}"
          }
          .appendTo attachedForm
          # next.value = cs.encrypt_string next.value, cs.aes_key, iv
          next.disabled = true
          # @consolePrint decrypt(next.value, key, iv)
        # else
        #   console.log next.type

  # Add the iv to the form
  $('<input type="hidden">').attr {
    id: "#{AES_PARAMS}_#{IV_PARAM}"
    name: "#{AES_PARAMS}[#{IV_PARAM}]"
    value: "#{forge.util.encode64 iv}"
  }
  .appendTo attachedForm
  true

@cinnamonroll.sec.ajax_submit = (attachedForm, ev) ->
  cs.encrypt_form attachedForm

  $.ajax {
    type: attachedForm.method
    url: attachedForm.action
    data: $(attachedForm).serialize()
  }
  .done (data, status, jq) ->
    # console.log "done: data: #{data}"
    replacePageContent data
  .fail (jq, status, e) ->
    # console.log "fail: jq: #{jq.status}"
    if jq.status == NO_KEY_STATUS
      cs.req_aes_key -> cs.ajax_submit attachedForm, ev
    else
      replacePageContent jq.responseText

  ev.preventDefault()

# Static code
# Check if we are encrypting this session
if !@cinnamonroll.sec.NO_ENCRYPTION
  if `window.location.protocol == "https:"`
    cs.NO_ENCRYPTION = true
  else if storageAvailable 'sessionStorage'
    cs.NO_ENCRYPTION = sessionStorage.getItem ENC_ACTIVE_PARAM
    if !cs.NO_ENCRYPTION
      cs.NO_ENCRYPTION = false
    else
      cs.NO_ENCRYPTION = JSON.parse cs.NO_ENCRYPTION
  else
    cs.NO_ENCRYPTION = false

# If we don't have an aes key, load it or request one
if !@cinnamonroll.sec.aes_key
  # Only if we are encrypting
  unless cs.NO_ENCRYPTION
    if isLocalStorageAvailable
      key = localStorage.getItem AES_KEY_PARAM
      if key
        cs.aes_key = forge.util.decode64 key
      else
        onPageLoad cs.req_aes_key
    else
      onPageLoad cs.req_aes_key

# Encrypt all forms on the page on submit
# onPageLoad -> $('form').attr 'onsubmit', "return cinnamonroll.sec.encrypt_form(this)"
onPageLoad -> $('form').preventDoubleSubmission().submit (ev) ->
  # cs.ajax_submit this, ev
  cs.encrypt_form this
