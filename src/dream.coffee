line = 1
column = 0
last_line_column = 0
i = 0
l = null
ch = null
code = ""

compile = (node, opts)->
  if typeof node is "string"
    rootnode = parse node
    csource = compile rootnode
    if opts and opts.module
      defs = rootnode.value.filter((n)-> n.value[0].value is "def").map (n)-> mung n.value[1].value
      return "module.exports = (function (window,global,js,console){" + csource + "return {" + defs.join() + "};})(undefined,undefined,global,console);"
    else
      return csource
  switch node.type
    # "Program" (programNode node opts)
    when "Symbol" then mung node.value
    when "String", "Keyword" then node.value
    when "Bool", "Nil", "Number" then JSON.stringify node.value
    when "RegExp" then regNode node
    when "Map" then mapNode node
    when "Array" then arrayNode node
    when "Comment" then ""
    else
      switch node.value[0].value
        when "def", "def-" then defNode node
        when "fn" then fnNode node
        when "do" then doNode node
        when "if" then ifNode node
        when "try" then tryNode node
        #when "else" then elseNode node
        when "while" then whileNode node
        when "switch" then switchNode node
        when "set!", "-=", "+=" then "(" + assignNode(node) + ")"
        when "=", "!=", "+", "-", "*", "/", "%", "and", "or" then "(" + opNode(node) + ")"
        when "<", ">", "<=", ">=" then (op2Node node)
        when "in", "!in" then inNode node
        when "!", "not" then notNode node
        when "aget" then agetNode node
        else callNode node

rootNode = (node, opts)->
  body = node.value.map((n)-> compile n).join ";"
  if opts and opts.module
    defs = node.value.filter((n)-> n.value[0].value is "def").map (n)-> mung n.value[1].value
    #defs = "module.exports = {" + defs.join() + "};"
    "module.exports = (function (window,global,js,console){" + body + "; return {" + defs.join() + "};})(undefined,undefined,global,console);"
    #body + ";" + defs
  else
    body + ";"

evaL = (code)->
  eval compile code

regNode = (node)->
  #"new RegExp(\"" + node.value + "\",\"" + node.flags + "\")"
  "new RegExp(" + node.value + ",\"" + node.flags + "\")"

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
      #ret += "=" + (argsNode node.value[2]) + "=>{"
      ret += "= function" + (argsNode node.value[2]) + "{"
    else
      ret = "function " + (compile node.value[1])
      # set! ret (+ ret " = function" (argsNode (aget node.value 2)) "{")
      ret += (argsNode node.value[2]) + "{"
    ret += (node.value.slice 3).map((n)-> compile n).join(";") + ";}"
    # (node.value.slice 2) .map (fn (n) (compile n)) .join ";"

argsNode = (node)->
  "(" + node.value.map((n)-> n.value).join() + ")"
  
fnNode = (node)->
  #ret = argsNode(node.value[1]) + "=>{"
  ret = "function" + argsNode(node.value[1]) + "{"
  ret += (node.value.slice 2).map((n)-> compile n).join(";") + ";}"

doNode = (node)->
  node.value.slice(1).map((n)-> compile n).join(";")+";"

# ifNode = (node)->
#   ret = "if(" + (compile node.value[1]) + "){"
#   ret += node.value[2].value.map((n)-> compile n).join(";") + ";}"
#   ret += (node.value.slice 3).map((n)-> elseNode n).join("")
#
# elseNode = (node)->
#   if node.value[1].value is "if"
#     ret = "else if(" + (compile node.value[2]) + "){" + node.value[3].value.map((n)-> compile n).join(";") + ";}"
#   else
#     ret = "else{" + node.value[1].value.map((n)-> compile n).join(";") + ";}"

ifNode = (node)->
  ret = "if(" + compile(node.value[1]) + "){"
  ret += compile(node.value[2])
  if node.value[3]
    ret += "}else{" + compile(node.value[3])
  ret += "}"

tryNode = (node)->
  i = node.value.findIndex (n)-> n.type is "List" and n.value[0].value is "catch"
  ret = "try{" + node.value.slice(1, i).map((n)-> compile n).join(";") + ";}"
  # console.log i node (aget node.value 1)(aget node.value 2)
  ret += "catch(" + compile(node.value[i].value[1]) + ")"
  ret += "{" + node.value[i].value.slice(2).map((n)-> compile n).join(";") + ";}"
  if i < node.value.length - 1
    ret += "finally{" + doNode(node.value[i+1]) + "}"
  ret
   
whileNode = (node)->
  ret = "while(" + (compile node.value[1]) + "){"
  ret += (node.value.slice 2).map((n)-> compile n).join(";") + ";}"

# switchNode = (node)->
#   ret = "switch(" + (compile node.value[1]) + "){"
#   node.value.slice(2).forEach(
#     (n)->
#       if n.value[0].value isnt "else"
#         i = n.value.findIndex (n)-> n.type is "Line"
#         n.value.slice(0, i).forEach((n)-> ret += "case " + (compile n) + ":")
#         ret += (n.value.slice i).map((n)-> compile n).join(";") + ";break;"
#       else
#         ret += "default:" + n.value[1].value.map((n)-> compile n).join(";") + ";break;")
#   ret += "}"

switchNode = (node)->
  ret = "switch(" + compile(node.value[1]) + "){"
  j = 2
  while j < node.value.length # - 1
    n = node.value[j]
    m = node.value[j+1]
    j += 2
    if m
      if n.type is "List"
        ret += n.value.map((n)-> "case " + compile(n) + ":").join("")
      else
        ret += "case " + (compile n) + ":"
      ret += (compile m) + ";break;"
    else
      ret += "default:" + (compile n)
      break
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

op2Node = (node)->
  i = 2
  ret = []
  while i <= node.value.length - 1
    ret.push [(compile node.value[i-1]), compile(node.value[i])]
    i += 1
  ret.map((n)-> n[0] + node.value[0].value + n[1]).join "&&"

inNode = (node)->
  c = compile node.value[1]
  if node.value[0].value is "in"
    #(compile node.value[1]) + " in " + (compile node.value[2])
    #node.value[2].value.map((n)-> c + "===" + compile(n)).join "||"
    (compile node.value[2]) + ".indexOf(" + (compile node.value[1]) + ")> -1"
  else
    #"!(" + (compile node.value[1]) + " in " + (compile node.value[2]) + ")"
    #node.value[2].value.map((n)-> c + "!==" + compile(n)).join "&&"
    (compile node.value[2]) + ".indexOf(" + (compile node.value[1]) + ")===-1"

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
        #mung(m.value.substring(1)) + "(" + node.value.slice(1).map((n)-> compile n).join() + ")"
        #"(" + compile(node.value[1]) + ")." + mung(m.value.substring(1)) + "(" + node.value.slice(2).map((n)-> compile n).join() + ")"
        compile(node.value[1]) + "." + mung(m.value.substring(1)) + "(" + node.value.slice(2).map((n)-> compile n).join() + ")"
      else if m.value.endsWith(".")
        "new " + mung(m.value.substring(0,m.value.length - 1)) + "(" + node.value.slice(1).map((n)-> compile n).join() + ")"
      else
        mung(m.value) + "(" + node.value.slice(1).map((n)-> compile n).join() + ")"
    else
      (compile m) + "(" + node.value.slice(1).map((n)-> compile n).join() + ")"

parse = (c)->
  code = clean c
  i = 0
  line = 1
  column = 0
  read()
  while ch in [" ", "\n"] then read()
  readLine()
  ast = readBlock {value: [{value: "do", type: "Symbol"}], type: "Line", root: true, loc: {}}
  removeComment ast
  # rewriteSymbol ast
  rewriteSoloNodeLine ast
  rewriteInlineIf ast
  rewriteInlineFn ast
  rewriteIfElse ast
  rewriteTryCatch ast
  rewriteSwitch ast
  markReturn ast
  markReturnFn ast
  rewriteReturn ast

clean = (code)->
  # .replace (code.replace #"\\r\\f"g "") #"\\t"g " "
  code.replace(/\r\f/g, "").replace /\t/g, " "

rewriteSymbol = (node)->
  switch node.type
    when "Symbol"
      if node.value is "true" or node.value is "false"
        node.type = "Bool"
        node.value = JSON.parse node.value
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
    when "List", "Line", "Map", "Array" then node.value.forEach (t)-> rewriteSymbol t
  node

rewriteSoloNodeLine = (node)->
  if node.type is "Line" and node.value.length is 1
    temp = node.value[0]
    rewriteSoloNodeLine temp
    node.value = temp.value
    node.type = temp.type
    node.loc = temp.loc
  else if node.type in ["Line", "List"]
    node.value.forEach (n)-> rewriteSoloNodeLine n

rewriteInlineIf = (node)->
  if node.type in ["Line", "List"]
    if node.value.length > 2 and node.value[node.value.length-2].value is "if" and node.value[node.value.length-2].type is "Symbol"
      t2 = node.value.pop()
      t1 = node.value.pop()
      if node.value.length > 1
        t3 = { type:"List", value:node.value, loc:{start:node.value[0].loc.start, end:node.value[node.value.length-1].loc.end}}
      else
        t3 = node.value[0]
      node.value = [t1,t2,t3]
    node.value.forEach (n)-> rewriteInlineIf n

rewriteInlineFn = (node)->
  if node.type in ["Line", "List"]
    i = node.value.findIndex((t)-> t.value is "fn" and t.type is "Symbol")
    if i > 0
      fnv = node.value.splice i
      node.value.push {type:"List", value:fnv, loc:{start:fnv[0].loc.start,end:fnv[fnv.length-1].loc.end}}
    node.value.forEach (n)-> rewriteInlineFn n

rewriteSwitch = (node)->
  if node.type is "Line"
    if node.value[0].value is "switch"
      node.value.splice(2).forEach(
        (n, i)->
          j = n.value.findIndex (n)-> n.type is "Line"
          if n.value[0].value isnt "do"
            body = n.value.splice(j)
            if body.length is 1
              body = body[0]
            else
              body = {value:[{value: "do", type: "Symbol"}].concat(body), type: "Line"}
            if n.value.length is 1
              n = n.value[0]
              node.value.push n
            else if n.value.length > 1
              n.type = "List"
              node.value.push n
            # else
            #  set! n {:value n.value :type "List"}
            node.value.push body
          else
            node.value.push n
      )
    node.value.forEach (n)-> rewriteSwitch(n)

markReturn = (node, disabled)->
  if node.root
    return node.value.forEach (n)-> markReturn(n, true)
  switch node.type
    when "Map", "Array","RegExp", "String", "Symbol", "Keyword", "Number", "Bool", "Nil"
      if not disabled
        node.return = true
    when "List", "Line"
      switch node.value[0].value
        when "def", "def-"
          if node.value.length > 3
            markReturn node.value[node.value.length-1]
        when "switch"
          node.value.slice(2).forEach(
            (n, i)->
              if i%2 is 1 or i is node.value.length - 3
                markReturn n)
          # (node.value.slice 2).forEach(
          #   (n)->
          #     if n.value[0].value is "else"
          #       elsebody = n.value[1].value
          #       markReturn elsebody[elsebody.length-1]
          #     else
          #       markReturn n.value[n.value.length-1])
        when "do"
          markReturn node.value[node.value.length-1]
        when "if"
          markReturn node.value[2]
          if node.value[3]
            markReturn node.value[3]
          # ifbody = node.value[2].value
          # markReturn ifbody[ifbody.length-1]
          # (node.value.slice 3).forEach(
          #   (n)->
          #     if n.value[1].value is "if"
          #       markReturn n.value[3].value[n.value[3].value.length-1]
          #     else
          #       markReturn n.value[1].value[n.value[1].value.length-1])
        else
          if not disabled
            node.return = true

markReturnFn = (node)->
  if node.type in ["List", "Line"]
    if node.value[0] and node.value[0].value is "fn" and node.value[0].type is "Symbol"
      markReturn node.value[node.value.length-1]
    node.value.forEach (n)-> markReturnFn n

rewriteReturn = (node)->
  if node.return
    sw = true
    if node.type in ["List", "Line"] and Boolean(node.value[0]) and node.value[0].type is "Symbol" and (node.value[0].value is "throw" or node.value[0].value is "return")
      sw = false
    if sw
      temp = [{value: "return", type: "Symbol"}, {value: node.value, type: node.type, loc: node.loc}]
      node.type = "List"
      node.value = temp
  if node.type in ["Line", "List"]
    node.value.forEach (n)-> rewriteReturn n
  node

removeComment = (node)->
  switch node.type
    when "List", "Line"
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

# rewriteIfElse = (node)->
#   node.value.forEach(
#     (n)->
#       if n.type is "Line"
#         if n.value[0].type is "Symbol"
#           if n.value[0].value is "if"
#             body = {value: n.value.splice(2), type: "List"}
#             rewriteIfElse body
#             n.value.push body
#           else if n.value[0].value is "else"
#             if n.value[1].value is "if"
#               k = 3
#             else
#               k = 1
#             body = {value: n.value.splice(k), type: "List"}
#             rewriteIfElse body
#             n.value.push body
#         rewriteIfElse n)
#   allif =
#     node.value.reduce(
#       (a, n, i)->
#         if n.type is "Line" and n.value[0].value is "if" and n.value[0].type is "Symbol"
#           a.push [i, n]
#         a
#       , [])
#   k = -1
#   while k < allif.length - 1
#     k += 1
#     l = allif[k][0]
#     n = allif[k][1]
#     while (j = node.value.findIndex (n)-> n.type is "Line" and n.value[0].value is "else") > -1
#       if j is l + 1
#         m = node.value.splice j, 1
#         n.value.push m[0]
#       else
#         break
#     throw new Error("else without if at line:"+node.value[j].loc.start.line+" column:"+node.value[j].loc.start.column) if j > -1 and j < l
#   node

rewriteIfElse = (node)->
  node.value.forEach(
    (n)->
      if n.type is "Line"
        if n.value[0].value is "if"
          body = [{value: "do", type: "Symbol"}]
          body = {value: body.concat(n.value.splice(2)), type: "Line"}
          # rewriteIfElse body
          n.value.push body
        else if n.value[0].value is "else"
          n.value.splice 0, 1
          n.elseif = true
          body = [{value: "do", type: "Symbol"}]
          if n.value[0].value is "if"
            k = 2
            body = {value: body.concat(n.value.splice(k)), type: "Line"}
            n.value.push body
          else
            k = 0
            n.value = body.concat(n.value.splice(k))
          # rewriteIfElse body
        rewriteIfElse n)

  i = node.value.length - 1
  while i > 0
    n = node.value[i]
    m = node.value[i-1]
    if n.elseif and m.type is "Line" and  (m.elseif or m.value[0].value is "if")
      # m.value.push (aget (node.value.splice i 1) 0)
      m.value = m.value.concat (node.value.splice i, 1)
    i -= 1
  node

rewriteTryCatch = (node)->
  if node.type in ["Line", "List"]
    node.value.forEach (n)-> (rewriteTryCatch n)
    i = 0
    while i > -1
      i = node.value.findIndex (n)-> n.type is "Line" and n.value[0].value is "try"
      return if i is -1
      j = node.value.findIndex (n)-> n.type in ["Line", "List"] and  n.value[0].value is "catch"
      if j is -1 or j isnt i + 1
        throw new Error("try without a catch at " + node.value[i].loc.start.line + ":" + node.value[i].loc.start.column)
      # console.log i j node.value (aget (aget node.value j) :value)
      n = node.value[i]
      n.type = "List"
      k = node.value.splice(j, 1)[0]
      k.type = "List"
      node.value[i].value.push k
      j = node.value.findIndex (n)-> n.type in ["Line", "List"] and n.value[0].value is "finally"
      if j is i + 1
        k = node.value.splice(j, 1)[0]
        k.type = "List"
        node.value[i].value.push k
  node

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
  if ll.bcomment
    token.value.push ll
    l = token
    return token
  while ll and ll.type isnt "Newline"
    token.value.push ll
    ll = readToken()
  ll = token.value[token.value.length-1]
  token.loc.end = ll.loc.end
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
  node = {value: "", type: "Symbol", loc: {start: {line, column}}}
  if ch in SPECIAL_CHARS
    node.value = ch
    node.loc.end = {line, column}
    return node
  while ch not in SPECIAL_CHARS
    if ch is "\\" then read()
    if ch is "\n"
      if node.value.length is 0
        node.value = "\\"
      else
        unread()
      break
    node.value += ch
    read()
  unread()
  node.loc.end = {line, column}
  read()
  if node.value is ""
    null
  else
    if node.value is "true" or node.value is "false"
      node.type = "Bool"
      node.value = JSON.parse node.value
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
        # node.value = node.value.substring 1
        node.value = "\"" + node.value.substring(1) + "\""
    node

readDispatch = ->
  read()
  switch ch
    when " " then readComment()
    when "!" then readBlockComment()
    when "\""
      node = readString()
      node.type = "RegExp"
      node.value = node.value.replace /\\/g , "\\\\"
      node.flags = ""
      if ch not in SPECIAL_CHARS
        node.flags = readSymbol().value
      node
    else
      #readComment()
      #unread()
      switch tv = readToken().value
        when "re"
          node = readToken()
          throw new Error "RegExp must be a string" if node.type isnt "String"
          node.type = "RegExp"
          node.flags = ""
          if ch not in SPECIAL_CHARS
            node.flags = readSymbol().value
          node
        else
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
  indent = column - 1
  token = {value: [], type: "Comment", bcomment: true, loc: {start: {line, column: (column - 1)}}}
  t = readToken()
  while t
    if t.type is "Newline" and t.loc.end.column < indent
      break
    token.value += t.value
    t = readToken()
  token.loc.end = {line, column}
  token
  #readLine()
  #readBlock token
  #while ch
  #  token.value += "\n" + readComment()
  #  nl = readNewline()
  #  break if nl.loc.end.column <= indent
  #unread()
  #token.loc.end = {line, column}
  #read()
  #token


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
      #switch ch
      #  when "t"
      #    token.value += "\t"
      #  when "n"
      #    token.value += "\n"
      #  when "f"
      #    token.value += "\f"
      #  when "b"
      #    token.value += "\b"
      #  when "r"
      #    token.value += "\r"
      #  when "\"", "\\"
      #    token.value += ch
      #  else
      #    #if ch is "u" and Util.isDigit ch
      #    #  token.value += readUnicodeChar()
      #    #else
      #    #  throw new Error("Unsupported escape character: \\" + ch)
      #    token.value += ch
      token.value += "\\"
      token.value += ch
    else
      token.value += ch
  token.value = "\"" + token.value + "\""
  token.loc.end = {line, column}
  read()
  token

read = ->
  if i is code.length
    i++
  if i >= code.length
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

String::forEach = (f)->
  for ch in @
    f ch

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

SPECIAL_CHARS = ["(", ")", "[", "]", "{", "}", " ", "\n", null, "\""]
NUMBER = /^[-+]?(0b[01]+|0o[0-7]+|0x[\da-f]+|\d*\.?\d+(?:e[+-]?\d+)?)$/

module.exports = {compile,parse,eval:evaL}
