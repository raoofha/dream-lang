display = require("./display")
rx = require("./rx")(display)
Time = require("./time")
Mouse = require("./mouse")
Key = require("./key")
htags = require "./htags"
htags.import()


prompt = "> "
input = rx.Cell ""
termhistory = rx.Array []
cursor_x = rx.Cell 19
cursor_y = rx.Cell 0

cursor_width = rx.Cell 10
cursor_height = rx.Cell 19
mode = "insert"
#cursor_x.subscribe -> console.log cursor_x.get()
#cursor_y.subscribe -> console.log cursor_y.get()
window.addEventListener "keydown", (e)->
  e.preventDefault()
  #console.log e.keyCode
  if mode is "insert"
    if e.keyCode not in Object.values Key.special
      input.set input.get() + e.key #if e.key is ' ' then '&nbsp' else e.key
    else if e.keyCode is Key.ENTER
      termhistory.push input.get()
      input.set ""
    else if e.keyCode is Key.BACKSPACE
      input.set input.get().substring(0,input.get().length-1)
    else if e.keyCode is Key.UP
      cursor_y.set cursor_y.get() - cursor_height.get()
    else if e.keyCode is Key.DOWN
      cursor_y.set cursor_y.get() + cursor_height.get()
    else if e.keyCode is Key.LEFT
      cursor_x.set cursor_x.get() - cursor_width.get()
    else if e.keyCode is Key.RIGHT
      cursor_x.set cursor_x.get() + cursor_width.get()
    window.scrollTo(0,document.body.scrollHeight)
  if mode is "normal"
    if e.keyCode is Key.K
      cursor_y.set cursor_y.get() - cursor_height.get()
    else if e.keyCode is Key.J
      cursor_y.set cursor_y.get() + cursor_height.get()
    else if e.keyCode is Key.H
      cursor_x.set cursor_x.get() - cursor_width.get()
    else if e.keyCode is Key.L
      cursor_x.set cursor_x.get() + cursor_width.get()
  if e.keyCode is Key.ESCAPE
    mode = "normal"
  if e.keyCode is Key.I
    mode = "insert"

class TextBuffer
  constructor:->
  putAt: (linenumber,index,value)->

cursor = ->
  div style:
    backgroundColor: "rgba(255,255,255,0.6)"
    height: cursor_height
    width: cursor_width
    position: "absolute"
    left: cursor_x
    top: cursor_y
terminal = ->
  div {style:"",onClick:-> console.log("asdf")}, [
    cursor()
    #div termhistory
    #div rx.add Time.hour, ":", Time.minute, ":", Time.second, ":", Time.millisecond
    #div Time.clock
    #div Time.clock
    #div rx.add Mouse.x, ",", Mouse.y
    #div style:{width:20,height:20,backgroundColor:"white",left:Mouse.x,top:Mouse.y,position:"absolute"}
    termhistory.map (h)-> div [prompt,h]
    div rx.add prompt, input
  ]

editor = ->
  div [
    cursor()
  ]

#main = terminal
main = editor
