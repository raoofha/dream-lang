rx =
  add: (args...)->
    cells = args.filter (a)-> a instanceof rx.Cell
    c = rx.Cell()
    f = -> c.set args.reduce (pre,cur)-> ( if pre instanceof rx.Cell then pre.get() else pre ) + ( if cur instanceof rx.Cell then cur.get() else cur)
    #f = ->
    #  c.set a.get() + b.get()
    f()
    #c.watch [a,b], -> c.set f()
    #a.subscribe f
    #b.subscribe f
    cells.forEach (cell)-> cell.subscribe f
    c
rx.Cell = class Cell
  constructor: (@_value)->
    @_subs = []
    return new rx.Cell arguments... unless this instanceof rx.Cell
  set: (value)->
    @_value = value
    @_notify()
    @
  get: -> @_value
  subscribe: (f)->
    @_subs.push f
    if @_subs.length is 1 and @onFirstSub
      @onFirstSub.call(this)

  _notify: -> @_subs.forEach (sub)-> sub()
  watch: (arr,f)->
    arr.forEach (a)-> a.subscribe(f)
rx.Array = class Array
  constructor: (@_value)->
    @_subs = []
    return new rx.Array arguments... unless this instanceof rx.Array
  push: (value)->
    @_value.push value
    #@_notify()
    display.update()
    @
  get: (index)-> @_value
  subscribe: (f)->
    @_subs.push f
    if @_subs.length is 1 and @onFirstSub
      @onFirstSub.call(this)

  _notify: -> @_subs.forEach (sub)-> sub()
  map: (f)->
    @_value.map (v)-> f(v)
module.exports = rx
