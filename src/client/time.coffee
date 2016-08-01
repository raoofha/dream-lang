rx = require("./rx")()

time = {}
time.millisecond = rx.Cell() #date.getMilliseconds()
time.millisecond.onFirstSub = ->
  this.set (new Date).getMilliseconds()
  setInterval (=> this.set (new Date).getMilliseconds() ), 1
time.second = rx.Cell() #date.getSeconds()
time.second.onFirstSub = ->
  f = => this.set (new Date).getSeconds()
  f()
  setTimeout (=> f() ; setInterval f, 1000),  (1000-(new Date).getMilliseconds())
time.minute = rx.Cell() #date.getMinutes()
time.minute.onFirstSub = ->
  #this.set (new Date).getMinutes()
  #setTimeout (=> setInterval (=> this.set (new Date).getMinutes() ), 60000), (60 - (new Date).getSeconds())*1000
  f = => this.set (new Date).getMinutes()
  f()
  setTimeout (=> f() ; setInterval f, 60000), (60 - (new Date).getSeconds())*1000
time.hour = rx.Cell() #date.getHours()
time.hour.onFirstSub = ->
  f = => this.set (new Date).getHours()
  f()
  setTimeout (=> f() ; setInterval f, 3600000), (60 - (new Date).getMinutes())*60000
time.clock = rx.Cell()
time.clock.onFirstSub = ->
  f = =>
    date = new Date
    this.set date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() # + ":" + date.getMilliseconds()
  f()
  #setInterval f,1
  setInterval f,1000

module.exports = time
