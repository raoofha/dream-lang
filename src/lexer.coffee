line = 1
column = 0 ; last_line_column = 0
i = 0 ; l = null ; ch = null ; code = ""

tokenize = (c)->
  code = c
  read()
  readLine()
  readBlock {value: [], type: "Program",loc:{}}

readToken = ->
  while ch is " "
    read()
  switch ch
    when "\n" then readNewline()
    when "\"" then readString()
    when "(" then readGroup("List",")")
    when "[" then readGroup("Array","]")
    when "{" then readGroup("Map","}")
    else readSymbol()

readLine = ->
  ll = readToken()
  if not ll
    l = null
    return null
  token = {value: [], type: "Line", loc: ll.loc}
  while ll and ll.type isnt "Newline"
    token.value.push ll
    ll = readToken()
  #if token.value.length is 1
  #  token = token.value[0]
  if ll
    token.loc.end = ll.loc.end
  else
    ll = token.value[token.value.length-1]
    token.loc.end = ll.loc.end
  if token.value.length is 0
    token = null
  l = token
  token


readBlock = (token)->
  return null if not l
  #indent = l.loc.start.column - 1
  indent = l.loc.start.column
  while l
    if l.loc.start.column < indent then break
    else if l.loc.start.column > indent
      readBlock previous_l
    else
      token.value.push l
      previous_l = l
      readLine()
  if l
    token.loc.end = l.loc.end
  else
    token.loc.end = previous_l.loc.end
  token
  

readGroup = (type, closeSym)->
  token = {value: [], type, loc: {start: {line, column}}}
  read()
  while ch isnt closeSym
    if ch is null
      throw new Error("EOF while reading at line:" + token.loc.start.line + " column:" + token.loc.start.column)
    t = readToken()
    token.value.push t if t and t not in SPECIAL_CHARS and t.type isnt "Newline"
  token.loc.end = {line, column}
  read()
  token

readSymbol = ->
  token = {value: "", type: "Symbol", loc: {start: {line, column}}}
  if ch in SPECIAL_CHARS
    token.value = ch
    token.loc.end = {line, column}
    return token
  while ch not in SPECIAL_CHARS
    if ch is "\\" then read()
    if ch is "\n"
      if token.value.length is 0
        token.value = "\\"
      else
        unread()
      break
    token.value += ch
    read()
  #unread() if ch is "\n"
  unread()
  token.loc.end = {line, column}
  read()
  if token.value is ""
    null
  else
    token
  
readDispatch = ->
  read()
  switch ch
    #when " " "!" then (readComment) ; return token
    when "\""
      token = readString()
      token.type = "RegExp"
      token
    else
      readComment()
      #throw (js.Error. "dispatch not defined")
readComment = ->
  token {value: "", type: "Comment", loc: {start: {line, column}}}
  while ch not in ["\n", null] then read()
  unread()
  token.loc.end = {line, column}
  token
readNewline = ->
  while ch in [" ", "\n"]
    while ch is "\n" then read()
    token = {value: "", type: "Newline", loc: {start: {line, column}}}
    while ch is " "
      token.value += ch
      read()
  unread()
  token.loc.end = {line, column}
  read()
  token
readString = ->
  token = {value: "", type: "String", loc: {start: {line, column}}}
  while read() isnt "\""
    throw new Error("EOF while reading") if !ch
    if ch is "\\"
      read()
      throw new Error("EOF while reading") if !ch
      switch ch
        when "t"
          token.value += "\t"
        when "n"
          token.value += "\n"
        when "f"
          token.value += "\f"
        when "b"
          token.value += "\b"
        when "r"
          token.value += "\r"
        when "\"", "\\"
          token.value += ch
        else
          if ch is "u" and Util.isDigit ch
            token.value += readUnicodeChar()
          else
            throw new Error("Unsupported escape character: \\" + ch)
    else
      token.value += ch
  token.loc.end = {line, column}
  read()
  token

read = ->
  if i is code.length
    ch = null
    column = 0
    return null
  ch = code[i]
  i++
  if ch is "\n"
    last_line_column = column
    line++
    column = 0
  else
    column++
  ch
unread = ->
  if i isnt 0
    i--
    if column is 0
      line--
      column = last_line_column
    else
      column--

SPECIAL_CHARS = ["(", ")", "[", "]", "{", "}", " ", "\n", null]
NUMBER =
  ///^
  [-+]?
  ( 0b[01]+                   # binary
  | 0o[0-7]+                  # octal
  | 0x[\da-f]+                # hex
  | \d*\.?\d+ (?:e[+-]?\d+)?  # decimal
  )
  $///

module.exports = {tokenize}
