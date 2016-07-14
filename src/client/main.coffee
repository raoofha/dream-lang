#RemoteStorage = require("./remotestorage")

#rs = new RemoteStorage()

window.addEventListener "keypress", (e)->
  console.log e.keyCode, e.key
window.addEventListener "keydown", (e)->
  console.log e.keyCode, e.key,e
