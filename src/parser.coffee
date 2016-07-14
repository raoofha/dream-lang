class Parser
  tokens:[]
  parse: (@code)->
    for ch in @code
      throw new Error("\\#{ch} character is not allowed") if not Util.isValidChar ch
    tokens = []
    @read()
    t = @readtoken()
    while t
      tokens.push t
      t = @readtoken()
    tokens
  readtoken: ->
    while @ch is " "
      @read()
    #throw new Error("EOF while reading") if not @ch
    if not @ch
      null
    else if @ch is "("
      @listToken()
    else if @ch is "["
      @vectorToken()
    else if @ch is "#"
      @dispatchToken()
    else if @ch is '"'
      @stringToken()
    else if @ch is "\n"
      @newlineToken()
    #else if @ch is " "
    #  throw new Error("bad indentation")
    else
      token = @symbolToken()
      n = Number(token.value)
      if not Number.isNaN n
        token.value = n
        token.type = "Number"
      else if token.value[0] is ":"
        token.type = "Keyword"
      token
  symbolToken: ->
    sym = ""
    token = {}
    token.type = "Symbol"
    token.first_line = @line
    token.first_column = @column
    #while Util.isSymbol @ch
    while @ch and (@ch isnt ' ' or @ch isnt '\n')
      @read() if @ch is '\\'
      sym += @ch
      @read()
    token.value = sym
    token.last_line = @line
    token.last_column = @column-1
    console.log sym,@ch
    token
  listToken: ->
    token = {}
    token.value = []
    token.type = "List"
    token.first_line = @line
    token.first_column = @column
    @read()
    while @ch isnt ")"
      token.value.push @readtoken()
    token.last_line = @line
    token.last_column = @column
    @read()
    token
  vectorToken: ->
    token = {}
    token.value = []
    token.type = "Vector"
    token.first_line = @line
    token.first_column = @column
    @read()
    t = @readtoken()
    while t and t.value isnt "]"
      token.value.push t
      t = @readtoken()
    throw new Error("EOF while reading") if not t
    token.last_line = @line
    token.last_column = @column
    @read()
    token
  stringToken: ->
    str = ""
    token = {}
    token.type = "String"
    token.first_line = @line
    token.first_column = @column
    while @read() isnt '"'
      throw new Error("EOF while reading") if not @ch
      if @ch is '\\'
        @read()
        throw new Error("EOF while reading") if not @ch
        switch @ch
          when 't'
            str += '\t'
          when 'n'
            str += '\n'
          when 'f'
            str += '\f'
          when 'b'
            str += '\b'
          when 'r'
            str += '\r'
          when '"', '\\'
            str += @ch
        if @ch is 'u' or Util.isDigit @ch
          str += @readUnicodeChar()
        else
          throw new Error("Unsupported escape character: \\" + @ch)
      else
        str += @ch
    token.last_line = @line
    token.last_column = @column
    @read()
    token




  typeconstructor_suger:
    List:   ['(',')']
    Map:    ['{','}']
    Vector: ['[',']']
    String: ['"','"']


  line:1
  column:0
  i:0
  read: ->
    if @i is @code.length
      @ch = null
      #@column += 1
      return null
    @ch = @code[@i]
    @i += 1
    if @ch is '\n'
      @line += 1
      @column = 0
    else
      @column += 1
    @ch
  unread: ->
    if @i isnt 0
      @i -= 1

Util =
  isSymbol: (str)-> /^[(^\d)\S]\S*$/.exec str or ""
  isValidChar: (char)-> /^[ ^\S]$/.exec char or ""
  isDigit: (char)->
    return false if not char
    c = char.charCodeAt 0
    c >= 48 and c <= 57

module.exports = Parser
