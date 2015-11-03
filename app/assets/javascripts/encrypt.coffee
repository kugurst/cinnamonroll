AES_PARAMS = "aes"
IV_PARAM = "iv"
KEY_PARAM = "key"
AES_IV_PARAM = AES_PARAMS + "[" + IV_PARAM + "]"
AES_KEY_PARAM = AES_PARAMS + "[" + KEY_PARAM + "]"

isRejectedInputElement = (name) ->
  rejected = ["commit", "authenticity_token", "utf8", AES_IV_PARAM]
  rejected.indexOf(name.toLowerCase()) >= 0


isApprovedInputElementType = (type) ->
  approved = ["text"]
  approved.indexOf(type.toLowerCase()) >= 0

# Returns a byte array containing the decrypted base64 string
decrypt = (string, key, iv) ->
  decipher = forge.cipher.createDecipher 'AES-CBC', key
  encrypted = forge.util.decode64 string
  decipher.start {iv: iv}
  decipher.update forge.util.createBuffer(encrypted, 'binary')
  decipher.finish()
  decipher.output.toString 'utf8'

# Returns a base64 string representing the given string
encryptString = (string, key, iv) ->
  cipher = forge.cipher.createCipher 'AES-CBC', key
  cipher.start {iv: iv}
  cipher.update forge.util.createBuffer(string, 'utf8')
  cipher.finish()
  forge.util.encode64 cipher.output.getBytes()

encryptForm = ->
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
          next.value = encryptString next.value, key, iv
          consolePrint decrypt(next.value, key, iv)

    # Add the iv to the form
    document.forms[0][AES_IV_PARAM].value = forge.util.encode64 iv
    document.forms[0][AES_KEY_PARAM].value = forge.util.encode64 key
  true
