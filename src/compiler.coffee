line = 1
column = 0
last_line_column = 0
i = 0
l = null
ch = null
code = ""

compile = (node)->
  return compile parse node if typeof node is "string"
  switch node.type
    when "Program" then rootNode node
    when "Symbol" then mung node.value
    when "Keyword", "Bool", "Nil", "Number" then JSON.stringify node.value
    when "String" then JSON.stringify node.value
    when "Map" then mapNode node
    when "Array" then arrayNode node
    when "Comment" then ""
    else
      switch node.value[0].value
        when "def" then defNode node
        when "def-" then defNode node
        when "fn" then fnNode node
        when "if" then ifNode node
        #when "else" then elseNode node
        when "while" then whileNode node
        when "switch" then switchNode node
        when "set!", "-=", "+=" then assignNode node
        when "=", "!=", "+", "-", "*", "/", "%", "and", "or" then opNode node
        when "!", "not" then notNode node
        when "aget" then agetNode node
        else callNode node

rootNode = (node)->
  defs = node.value.filter((n)-> n.value[0].value is "def").map (n)-> mung n.value[1].value
  defs = "module.exports = {" + defs.join() + "}"
  body = node.value.map((n)-> compile n).join ";"
  body + ";" + defs

mapNode = (node)->
  keys = node.value.filter((n,i)-> i % 2 is 0).map (n)-> compile n
  vals = node.value.filter((n,i)-> i % 2 is 1).map (n)-> compile n
  "{" + range(vals.length).map((i)-> keys[i] + ":" + vals[i]).join() + "}"

arrayNode = (node)->
  "[" + (node.value.map (n)-> compile n).join() + "]"

defNode = (node)->
  if node.value.length is 1
    ""
  else if node.value.length is 2
    "var " + (compile node.value[1])
  else if node.value.length is 3
    "var " + (compile node.value[1]) + " = " + (compile node.value[2])
  else
    if node.value[1].value.indexOf(".") > 0
      ret = (compile node.value[1])
      ret += "=" + (argsNode node.value[2]) + "=>{"
    else
      ret = "function " + (compile node.value[1])
      # set! ret (+ ret " = function" (argsNode (aget node.value 2)) "{")
      ret += (argsNode node.value[2]) + "{"
    ret += (node.value.slice 3).map((n)-> compile n).join(";") + ";}"
    # (node.value.slice 2) .map (fn (n) (compile n)) .join ";"

argsNode = (node)->
  "(" + node.value.map((n)-> n.value).join() + ")"
  
fnNode = (node)->
  ret = argsNode(node.value[1]) + "=>{"
  ret += (node.value.slice 2).map((n)-> compile n).join(";") + ";}"

ifNode = (node)->
  ret = "if(" + (compile node.value[1]) + "){"
  ret += node.value[2].value.map((n)-> compile n).join(";") + ";}"
  ret += (node.value.slice 3).map((n)-> elseNode n).join("")

elseNode = (node)->
  if node.value[1].value is "if"
    ret = "else if(" + (compile node.value[2]) + "){" + node.value[3].value.map((n)-> compile n).join(";") + ";}"
  else
    ret = "else{" + node.value[1].value.map((n)-> compile n).join(";") + ";}"
   
whileNode = (node)->
  ret = "while(" + (compile node.value[1]) + "){"
  ret += (node.value.slice 2).map((n)-> compile n).join(";") + ";}"

switchNode = (node)->
  ret = "switch(" + (compile node.value[1]) + "){"
  node.value.slice(2).forEach (n)->
    if n.value[0].value isnt "else"
      i = n.value.findIndex (n)-> n.type is "Line"
      n.value.slice(0, i).forEach((n)-> ret += "case " + (compile n) + ":")
      ret += (n.value.slice i).map((n)-> compile n).join(";") + ";break;"
    else
      ret += "default:" + n.value[1].value.map((n)-> compile n).join(";") + ";break;"
  ret += "}"

assignNode = (node)->
  op = node.value[0].value
  if op is "set!"
    op = "="
  (compile node.value[1]) + " " + op + " " + compile(node.value[2])

opNode = (node)->
  op = node.value[0].value
  if op is "and"
    op = "&&"
  else if op is "or"
    op = "||"
  else if op is "="
    op = "==="
  else if op is "!="
    op = "!=="
  node.value.slice(1).map((n)-> compile n).join(op)

notNode = (node)->
  op = node.value[0].value
  if op is "not"
    op = "!"
  "!" + (compile node.value[1])

agetNode = (node)->
  m1 = node.value[1]
  m2 = node.value[2]
  (compile m1) + "[" + (compile m2) + "]"

callNode = (node)->
  m = node.value[0]
  switch m.type
    when "Symbol"
      if m.value.startsWith(".-")
        (compile node.value[1]) + "." + mung m.value.substring(2)
      else if m.value.startsWith(".")
        mung(m.value.substring(1)) + "(" + node.value.slice(1).map((n)-> compile n).join() + ")"
      else if m.value.endsWith(".")
        "new " + mung(m.value.substring(0,m.value.length - 1)) + "(" + node.value.slice(1).map((n)-> compile n).join() + ")"
      else
        mung(m.value) + "(" + node.value.slice(1).map((n)-> compile n).join() + ")"
    else
      (compile m) + "(" + node.value.slice(1).map((n)-> compile n).join() + ")"

parse = (c)->
  code = c
  i = 0
  line = 1
  column = 0
  read()
  readLine()
  ast = readBlock({value: [], type: "Program",loc:{}})
  removeComment ast
  analyseNode ast
  preprocessIf ast

analyseNode = (node)->
  switch node.type
    when "Program" then node.value.forEach (t)-> analyseNode t
    when "Symbol" then analyseSymbol node
    when "Array" then analyseArray node
    when "Map" then analyseMap node
    when "List", "Line" then analyseList node
  node

analyseList = (node)->
  if node.type is "Line" and node.value.length is 1
    temp = node.value[0]
    analyseNode temp
    node.value = temp.value
    node.type = temp.type
    node.loc = temp.loc
  else
    node.value.forEach (t)-> analyseNode t
    analyseInlineIf node
    analyseInlineFn node

analyseInlineIf = (node)->
  if node.value.length > 2 and node.value[node.value.length-2].value is "if"
    t2 = node.value.pop()
    t1 = node.value.pop()
    if node.value.length > 1
      t3 = { type:"List", value:node.value, loc:{start:node.value[0].loc.start, end:node.value[node.value.length-1].loc.end}}
    else
      t3 = node.value[0]
    node.value = [t1,t2,t3]

analyseInlineFn = (node)->
  i = node.value.findIndex((t)-> t.value is "fn" and t.type is "Symbol")
  if i > 0
    fnv = node.value.splice i
    node.value.push {type:"List", value:fnv, loc:{start:fnv[0].loc.start,end:fnv[fnv.length-1].loc.end}}

removeComment = (node)->
  switch node.type
    when "List", "Line", "Program"
      i = node.value.findIndex (n)-> n.type is "Line" and n.value[0].type is "Comment"
      if i isnt -1
        node.value.splice i, 1
        removeComment node
      i = node.value.findIndex (n)-> n.type is "Comment"
      if i is -1
        node.value.forEach (n)-> removeComment n
      else
        node.value.splice i, 1
        removeComment node

preprocessIf = (node)->
  node.value.forEach(
    (n)->
      if n.type is "Line"
        if n.value[0].type is "Symbol"
          if n.value[0].value is "if"
            body = {value: n.value.splice(2), type: "List"}
            preprocessIf body
            n.value.push body
          else if n.value[0].value is "else"
            if n.value[1].value is "if"
              k = 3
            else
              k = 1
            body = {value: n.value.splice(k), type: "List"}
            preprocessIf body
            n.value.push body
        preprocessIf n)
  allif =
    node.value.reduce(
      (a, n, i)->
        if n.type is "Line" and n.value[0].value is "if"
          a.push [i, n]
        a
      , [])
  k = -1
  while k < allif.length - 1
    k += 1
    l = allif[k][0]
    n = allif[k][1]
    while (j = node.value.findIndex (n)-> n.type is "Line" and n.value[0].value is "else") > -1
      if j is l + 1
        m = node.value.splice j, 1
        n.value.push m[0]
      else
        break
    throw new Error("else without if") if j > -1 and j < l
  node

analyseMap = (node)->
  node.value.forEach (t)-> analyseNode t

analyseArray = (node)->
  node.value.forEach (t)-> analyseNode t

analyseSymbol = (node)->
  if node.value is "true" or node.value is "false"
    node.type = "Bool"
    node.value = Boolean node.value
  else if node.value is "nil"
    node.type = "Nil"
    node.value = null
  else
    m = node.value.match NUMBER
    if m
      node.value = Number node.value
      node.type = "Number"
    else if node.value[0] is ":"
      node.type = "Keyword"
      node.value = node.value.substring 1
    #else if node.value.length > 2
    #  o = node.value.substring node.value.length-2
    #  v = node.value.substring 0, node.value.length-2
    #  if o is "++"
    #    node.value = [{type:"Symbol",value:"+="},{type:"Symbol",value:v},{type:"Number",value:1}]
    #    node.type = "List"
    #  else if o is "--"
    #    node.value = [{type:"Symbol",value:"-="},{type:"Symbol",value:v},{type:"Number",value:1}]
    #    node.type = "List"


readToken = ->
  while ch is " " then read()
  switch ch
    when null then null
    when "\n" then readNewline()
    when "\"" then readString()
    when "#" then readDispatch()
    when "(" then readGroup("List",")")
    when "[" then readGroup("Array","]")
    when "{" then readGroup("Map","}")
    when ")", "]", "}" then throw new Error "unmatch char: " + ch + "at line:" + line + " column" + column
    else readSymbol()

readLine = ->
  ll = readToken()
  if not ll
    l = null
    return null
  token = {value: [], type: "Line", loc: ll.loc}
  while ll and ll.type isnt "Newline"
    token.value.push ll # if ll.type isnt "Comment"
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
  token.loc.start = l.loc.start
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
    when " " then readComment()
    when "!" then readBlockComment()
    when "\""
      token = readString()
      token.type = "RegExp"
      token
    else
      #readComment()
      throw new Error "dispatch not defined"

readComment = ->
  token = {value: "", type: "Comment", loc: {start: {line, column: column - 1}}}
  while ch not in ["\n", null]
    token.value += ch
    read()
  unread()
  token.loc.end = {line, column}
  read()
  token

readBlockComment = ->
  indent = column - 2
  token = {value: "", type: "Comment", loc: {start: {line, column: (column - 1)}}}
  while ch
    token.value += "\n" + readComment()
    nl = readNewline()
    break if nl.loc.end.column <= indent
  unread()
  token.loc.end = {line, column}
  read()
  token


readNewline = ->
  while ch in [" ", "\n"]
    while ch is "\n" then read()
    token = {value: "", type: "Newline", loc: {start: {line, column}}}
    while ch is " "
      token.value += ch
      read()
  unread() if ch
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

mung = (name)->
  ret = ""
  for ch in name
    s = CHAR_MAP[ch]
    if s
      ret += s
    else
      ret += ch
  ret

range = (n)-> [0...n]

CHAR_MAP =
  "-": "_"
  ":": "_COLON_"
  "+": "_PLUS_"
  ">": "_GT_"
  "<": "_LT_"
  "=": "_EQ_"
  "~": "_TILDE_"
  "!": "_BANG_"
  "@": "_CIRCA_"
  "#": "_SHARP_"
  "%": "_PERCENT_"
  "^": "_CARET_"
  "&": "_AMPERSAND_"
  "*": "_STAR_"
  "|": "_BAR_"
  "{": "_LBRACE_"
  "}": "_RBRACE_"
  "[": "_LBRACK_"
  "]": "_RBRACK_"
  "(": "_LPAREN_"
  ")": "_RPAREN_"
  "/": "_SLASH_"
  "?": "_QMARK_"
  ";": "_SEMICOLON_"
  "'": "_SINGLEQUOTE_"
  "\"": "_DOUBLEQUOTE_"
  "\\": "_BSLASH_"

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

module.exports = {compile,parse}
