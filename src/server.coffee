express = require("express")
bodyParser = require 'body-parser'
path = require 'path'

server = express()
httpserver = require("http").createServer(server)
httpserver.listen process.env.PORT or 4000
io = require("socket.io")(httpserver)
#server.listen process.env.PORT or 4000
#server.use express.static( path.join __dirname , "../src/client/assets")
server.use express.static( __dirname + "/assets")
server.use "/node_modules", express.static( path.join __dirname , "../node_modules")
server.use bodyParser.json()
server.use bodyParser.urlencoded(extended: false)
#---------------------------------------------------------------------------
server.use (err, req, res, next)-> res.json { error: err.message }
#---------------------------------------------------------------------------

io.on "connection", (socket)->
  console.log "a user connected"
  socket.on "disconnect", -> console.log "user disconnected"
  socket.on "newvalue", ({name,value})->
    db[name].set value
    #io.emit "newvalue", {name,value}
