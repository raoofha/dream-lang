class Lexer
  constructor: (@code)-> @i_lexeme = 0 ; @line = 1 ; @column = 0 ; @i = 0
  tokenize: ->
    @tokens = []
    @readLexemes()
    blocks = @readBlock()
    blocks.forEach (b)-> @cleanBlock b
    blocks
  cleanBlock: (block)->
    token = {}
    switch block[0]
      when "if"
        token.type = "If"
        token.value = block.slice(1)
      when "else"
        if block[1] is "if"
          token.type = "ElseIf"
          token.value = block.slice(2)
        else
          token.type = "Else"
          token.value = block.slice(1)
      when "class"
        token.type = "Class"
        token.value = block.slice(1)
      when "def"
        token.type = "Def"
        token.value = block.slice(1)
      when "fn"
        token.type = "Fn"
        token.value = block.slice(1)
      else
        if Array.isArray block[0]
          block[0].forEach (b)->
            @cleanBlock b
        else
          token.type = "FnCall"
          token.value = block.slice(1)
    token
  readBlock: (block=[])->
    #@nextLexeme()
    #fl = @lexeme.first_line
    #fc = @lexeme.first_column
    firstLexeme = @lexeme
    while true
      firstLine = []
      while @lexeme and @lexeme.type isnt "Newline"
        firstLine.push @lexeme
        block.push @lexeme
        beforeNewline = @lexeme
        @nextLexeme()
      while @lexeme and @lexeme.type is "Newline"
        lastNewline = @lexeme
        @nextLexeme()
      return block if not @lexeme
      #return block if lastNewline.value.length < firstLexeme.first_column - 1
      #d = lastNewline.value.length - firstLexeme.first_column + 1
      d = lastNewline.value.length - firstLexeme.first_column + 1
      return block if d < 0
      continue if d is 0
      #d = lastNewline.value.length - ( firstLexeme.first_column + firstLexeme.value.length )
      #continue if d is 0
      i = firstLine.length
      for lexeme in firstLine
        d = lastNewline.value.length - ( lexeme.first_column + lexeme.value.length )
        if d is 0
          break
        else if d < 0
          throw new Error "Bad indentation at line: #{lastNewline.last_line} column: #{lastNewline.last_column}"
        i--
      if d is 0
        block.push @readBlock block.splice -i, i
      else
        throw new Error "Bad indentation at line: #{lastNewline.last_line} column: #{lastNewline.last_column}"
  readToken: ->
    l = @nextLexeme()
    if l
      switch l.value
        when "(" then @readGroup "List", ")"
        when "[" then @readGroup "Array", "]"
        when "{" then @readGroup "Map", "}"
        else l
    else
      null
  readGroup: (type,closeSym)->
    token = {}
    token.value = []
    token.type = type
    token.first_line = @lexeme.first_line
    token.first_column = @lexeme.first_column
    t = @readToken()
    while t and t.value isnt closeSym
      token.value.push t
      t = @readToken()
    throw new Error "EOF file while reading" if not t
    token.last_line = @lexeme.last_line
    token.last_column = @lexeme.last_column
    token
  nextLexeme: ->
    l = @lexemes[@i_lexeme]
    @i_lexeme++ if l
    @lexeme = l
    l
  readLexemes: ->
    @lexemes = []
    @read()
    while @ch in [SPACE,NEWLINE]
      @read()
    @unread()
    while @readLexeme()
      @lexemes.push @lexeme
    @lexemes
  readLexeme: ->
    str = ""
    #@read()
    while @ch is SPACE
      @read()
    @lexeme = {}
    @lexeme.value = ""
    @lexeme.type = "Symbol"
    @lexeme.first_line = @line
    @lexeme.first_column = @column
    if @ch is NEWLINE
      return @readNewline()
    else if @ch is '"'
      return @readString()
    else if @ch is '#'
      return @readDispatch()
    while @ch not in [SPACE,NEWLINE,EOF]
      @read() if @ch is '\\'
      str += @ch
      @read()
    #if @ch is EOF
    #  @lexeme = null
    #  return null
    @lexeme.value = str
    @lexeme.last_line = @line
    @lexeme.last_column = @column
    @lexeme
  readDispatch: ->
    @lexeme.type = "Dispatch"
    @read()
    switch @ch
      when SPACE, BANG then @readComment() ; return @lexeme
      when DQUOTE
        @readString()
        @lexeme.type = "RegExp"
        return @lexeme
      else
        throw new Error "dispatch not defined"
  readComment: ->
    @lexeme.type = "Comment"
    while @ch not in [NEWLINE,EOF]
      @read()
    @lexeme.last_line = @line
    @lexeme.last_column = @column
    @lexeme
  readNewline: ->
    @lexeme.type = "Newline"
    while @read() is SPACE
      @lexeme.value += @ch
    @lexeme.last_line = @line
    @lexeme.last_column = @column
    @lexeme
  readString: ->
    @lexeme.type = "String"
    str = ""
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
    @lexeme.value = str
    @lexeme.last_line = @line
    @lexeme.last_column = @column
    @lexeme




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
primitiveType  = [
  "String"
  "Array"
  "Map"
  "Number"
  "Boolean"
  "Int"
  "Float"
  "RegExp"
  "Any"
]
pseudoFn2 =
  "(":")"
  "[":"]"
  "{":"}"
fns = [
  "+"
  "-"
  "*"
  "/"
  "is"
  "isnt"
]

EOF = null
SPACE = " "
BANG = "!"
NEWLINE = "\n"
NUMBER =
  ///^
  [-+]?
  ( 0b[01]+                   # binary
  | 0o[0-7]+                  # octal
  | 0x[\da-f]+                # hex
  | \d*\.?\d+ (?:e[+-]?\d+)?  # decimal
  )
  $///
