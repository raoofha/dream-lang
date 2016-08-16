#! /usr/bin/coffee

readline = require('readline')
dream = require("./dream")

rl = readline.createInterface({
  input: process.stdin
  output: process.stdout
  #prompt: "> "
  #terminal: false
})

rl.prompt()
rl.on "line", (q)->
  if q
    try
      console.log dream.eval q
      #c = dream.compile q
      #console.log c
      #console.log eval c
    catch e
      #console.log e.message
      console.log e
  rl.prompt()

###
process.stdin.on "data", (d)->
  process.stdout.write d.toString()
###
