rx = require("./rx")
htags = require "htags"
htags.import()
  


a = rx.Cell 5
b = rx.add a, rx.Cell 1

#setInterval (-> console.log b.get() ), 1000
#nowCell = rx.Cell()
#Object.defineProperty window, "now", get: -> nowCell.set Date.now()
now = rx.Cell()
now.onFirstSub = -> setInterval (=> this.set Date.now() ), 1
position = rx.Cell("0,0")
position.onFirstSub = -> window.addEventListener "mousemove", (e)=> this.set e.clientX + "," + e.clientY
#window.addEventListener "mousemove", (e)-> console.log e

uielement = ->
  div [
    "yeh"
    span now
  ]

#socket = io("http://localhost:4000/")
socket = io()
socket.emit "msg", "asdfsdf"

handler =
  get: (target, key)->
    #console.log target,key
    if key not in target
      target[key] = new Proxy({},handler)
    target[key]
  #set: (target, key, value)->
    #if key[0] isnt '_'
    #  target[key] = new Proxy(value,handler)
    #else
    #target[key] = value
db = new Proxy {}, handler


main =
  div [
    #h6 now
    h6 position
    h6 b
    h2 "hello world"
    #uielement()
    #uielement()
  ]


document.body.appendChild(main)
