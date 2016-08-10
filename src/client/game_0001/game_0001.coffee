
class Player
  constructor: (args...)->
    return new Player(args...) unless this instanceof Player
    @x = rx.Cell(30)
    @y = rx.Cell(30)
    @state = rx.Cell("idle")
    @face = rx.Cell 1
  left:->
    @x.set(@x.get()-2)
    #@$.css("transform","scaleX(-1)")
    @face.set -1
    @state.set("run")# if @state.get() isnt "run"
  right:->
    @x.set(@x.get()+2)
    @face.set 1
    @state.set("run")# if @state.get() isnt "run"
  render: ->
    div {style:{position:"absolute",left:rx.add(@x,"px"),top:rx.add(@y,"px"),transform:rx.add "scaleX(",@face,")"}}, img src:rx.add "img/animation-set/tim-", @state, "-50-b.gif"
tim = Player()


document.addEventListener "keydown", (e)->
  if e.keyCode in [Key.D, Key.RIGHT]
    tim.right()
  if e.keyCode in [Key.A, Key.LEFT]
    tim.left()
document.addEventListener "keyup", (e)-> tim.state.set("idle")




main = ->
  div [
    "محمد حسین"
    tim
  ]
