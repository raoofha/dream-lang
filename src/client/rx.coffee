display = null
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
  and: (args...)->
    cells = args.filter (a)-> a instanceof rx.Cell
    ret = rx.Cell()
    f = -> ret.set args.reduce (pre,cur)-> ( if pre instanceof rx.Cell then pre.get() else pre ) and ( if cur instanceof rx.Cell then cur.get() else cur)
    f()
    cells.forEach (cell)-> cell.subscribe f
    ret

class Base
  constructor: (@_value)->
    @_subs = []
    (display.subscribe => @reset()) if display
  reset: -> @_subs = []
  get: -> @_value
  set: (value,source)->
    if @_value isnt value
      @_value = value
      @_notify source
    @
  subscribe: (f,source)->
    @_subs.push f
    @_source = f if source
    if @_subs.length is 1 and @onFirstSub
      @onFirstSub.call(this)

  _notify: (source)-> @_subs.forEach (sub)=> if not (source and sub is @_source) then sub()

rx.Cell = class Cell extends Base
  constructor: (value)->
    return new rx.Cell arguments... unless this instanceof rx.Cell
    super(value)
  toggle: -> @set not @get()
  map11: (m)->
    ret = rx.Cell()
    f = =>
      ret.set m[@get()]
    f()
    @subscribe f
    ret
  watch: (arr,f)->
    arr.forEach (a)-> a.subscribe(f)
rx.Array = class Array extends Base
  constructor: (value)->
    return new rx.Array arguments... unless this instanceof rx.Array
    super(value)
  push: (value)->
    @_value.push value
    if display
      display.update()
    else
      @_notify()
    @
  map: (f)->
    @_value.map (v)-> f(v)
    #ret = rx.Cell()
    #ff = => ret.set @_value.map (v)-> f(v)
    #ff()
    #@subscribe ff
    #ret
    
#rx.Select = class Select extends Base
#  constructor: (value)->
#    return new rx.Select arguments... unless this instanceof rx.Select
#    super(value)
module.exports = (disp)-> display = disp if disp ; rx
