#! /usr/bin/coffee
###
readline = require('readline')

rl = readline.createInterface({
  input: process.stdin
  output: process.stdout
  #prompt: "> "
  #terminal: false
})

rl.prompt()
rl.on "line", (q)->
  console.log q
  rl.prompt()
###

###
repl = require("repl")

myrepl = repl.start()
#  prompt: "> "
###

nesh = require 'nesh'

nesh.loadLanguage 'coffee'

nesh.start {prompt:"> ",welcome:"",historyFile:"history.repl"}, (err, repl) ->
  return nesh.log.error err if err
  compiler = require("./compiler")
  repl.context.compiler = compiler
