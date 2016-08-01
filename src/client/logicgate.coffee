display = require("./display")
rx = require("./rx")(display)
htags = require "./htags"
htags.import()

v1 = rx.Cell true
v2 = rx.Cell false
v4 = rx.Cell "say something"
l1 = rx.Cell true
#l2 = rx.Array [true,false]
#l2 = rx.Enum {"true":true,"false":false}

lamp = ({value})->
  div style:{
    backgroundColor:value.map11 {true:"red",false:"gray"}
    borderRadius:"50%"
    width:20
    height:20
  }, onClick: (-> value.toggle())

main = ->
  div [
    "hello world"
    div svg width:"120", height:"100", xmlns:"http://www.w3.org/2000/svg", "xmlns:svg":"http://www.w3.org/2000/svg",
      g [
        path stroke:"#ffffff", "stroke-width":"5", d:"m19,8l42,0l0,0c23.19596,0 42,18.80404 42,42c0,23.19596 -18.80404,42 -42,42l-42,0l0,-84z"
        line stroke:"#ffffff", "stroke-width":"5", x1:"105", y1:"50", x2:"147", y2:"50"
        line stroke:"#ffffff", "stroke-width":"5", x1:"17", y1:"23", x2:"-29", y2:"23"
        line stroke:"#ffffff", "stroke-width":"5", x1:"17", y1:"77", x2:"-29", y2:"77"
      ]
    lamp value:l1
    lamp value:v2
    input type:"checkbox",checked:v1
    input type:"checkbox",checked:v2
    input type:"checkbox",checked:(rx.and v1,v2),disabled:true
    div v1
    div {style:backgroundColor:v1.map11 {true:"red",false:"gray"}},"asdsf"
    input type:"text",value:v4
    div v4
  ]
