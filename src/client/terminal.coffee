rx = require("./rx")
require("./util")
htags = require "htags"
htags.import()

KEY =
  ENTER: 13
  TAB: 9
  DELETE : 46
  INSERT : 45
  PAUSE: 19
  SCROLL: 145
  BACKSPACE : 8
  LEFT : 37
  RIGHT : 39
  UP : 38
  DOWN : 40
  HOME : 36
  END : 35
  PAGE_UP : 33
  PAGE_DOWN : 34
  SHIFT: 16
  CTRL: 17
  ALT: 18
  ESCAPE: 27
  META: 91
  HYPER: 0
  F1: 112
  F2: 113
  F3: 114
  F4: 115
  F5: 116
  F6: 117
  F7: 118
  F8: 119
  F9: 120
  F10: 121
  F11: 122
  F12: 123

prompt = "> "
input = rx.Cell ""
termhistory = rx.Array []

window.addEventListener "keydown", (e)->
  e.preventDefault()
  #console.log e.keyCode
  if e.keyCode not in Object.values KEY
    input.set input.get() + e.key #if e.key is ' ' then '&nbsp' else e.key
  else if e.keyCode is KEY.ENTER
    termhistory.push input.get()
    input.set ""
  else if e.keyCode is KEY.BACKSPACE
    input.set input.get().substring(0,input.get().length-1)
  window.scrollTo(0,document.body.scrollHeight)

terminal = ->
  div style:"", [
    #div termhistory
    termhistory.map (h)-> div [prompt,h]
    div rx.add prompt, input
  ]

display =
  update: ->
    $content = document.getElementById("content")
    $content.empty()
    $content.appendChild(main())

main = terminal
