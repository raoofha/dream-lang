rx = require("./rx")()

mouse = {}
mouse.x = rx.Cell 0
mouse.y = rx.Cell 0
mouse.x.onFirstSub = -> window.addEventListener "mousemove", (e)=> this.set e.clientX
mouse.y.onFirstSub = -> window.addEventListener "mousemove", (e)=> this.set e.clientY

module.exports = mouse
