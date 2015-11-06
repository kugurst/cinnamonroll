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
RSA_PAIR_PARAM = RSA_PARAM + "_" + KEY_PARAM
REJECTED_FORM_KEYS = ["commit", "authenticity_token", "utf8", AES_IV_PARAM]
APPROVED_FORM_ELEMENT_TYPES = ["text"]
MAX_ATTEMPTS = 3

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

onPageLoad = (func, args...) ->
  $(document).ready -> func args...
  $(document).on 'page:load', -> func args...


# Module function definitions #
@cinnamonroll.sec.send_pk = (success_func, fail_func, attempt = 0) ->
  cs.rsa_pair = rsa.generateKeyPair bits: 2048, workers: -1 if !cs.rsa_pair
  n64 = forge.util.encode64 cs.rsa_pair.publicKey.n.toString()
  e64 = forge.util.encode64 cs.rsa_pair.publicKey.e.toString()

  jqxhr = $.ajax {
    type: "POST"
    url: Routes.security_post_rsa_key_path()
    data: { "#{RSA_PAIR_PARAM}": { n: n64, e: e64 } }
  }
  .done (data, status, jq) ->
    success_func data, status, jq
  .fail (jq, status, e) ->
    if attempt < MAX_ATTEMPTS
      cs.send_pk success_func, fail_func, attempt + 1
    else
      fail_func jq, status, e

@cinnamonroll.sec.recv_aes_key = (data, status, jq, attempt = 0) ->
  jqxhr = $.ajax {
    type: "GET"
    url: Routes.security_get_aes_key_path()
  }
  .done (dat, stat, j) ->
    js = JSON.parse dat
    cs.aes_key = forge.util.decode64 js[AES_KEY_PARAM]
    if isLocalStorageAvailable
      localStorage.setItem AES_KEY_PARAM, cs.aes_key
  .fail (j, stat, e) ->
    if attempt < MAX_ATTEMPTS
      cs.recv_aes_key data, status, jq, attempt + 1
    else
      cs.set_no_enc

@cinnamonroll.sec.set_no_enc = ->
  cs.NO_ENCRYPTION = true

@cinnamonroll.sec.req_aes_key = ->
  cs.send_pk cs.recv_aes_key, cs.set_no_enc if !cs.rsa_pair

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

@cinnamonroll.sec.encrypt_form = ->
  stack = new Array()
  key = forge.random.getBytesSync 32
  iv = forge.random.getBytesSync 32

  stack.push(document.forms)
  while stack.length > 0
    next = stack.pop()
    if next not instanceof HTMLInputElement
      stack.push elem for elem in next
    else
      # Rails add some default form fields
      if !isRejectedInputElement next.name
        # For supported a wide variety of types
        if isApprovedInputElementType next.type
          next.value = cs.encrypt_string next.value, key, iv
          # @consolePrint decrypt(next.value, key, iv)

    # Add the iv to the form
    document.forms[0][AES_IV_PARAM].value = forge.util.encode64 iv
    document.forms[0][AES_KEY_PARAM].value = forge.util.encode64 key
  true

# Module variable definitions #
@cinnamonroll.sec.NO_ENCRYPTION = false

# If we don't have an aes key, load it or request one
if !@cinnamonroll.sec.aes_key
  if isLocalStorageAvailable
    key = localStorage.getItem AES_KEY_PARAM
    if key
      cs.aes_key = forge.util.decode64 key
    else
      onPageLoad cs.req_aes_key
  else
    onPageLoad cs.req_aes_key
